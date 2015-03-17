/*
 *  Copyright 2009, 2010 Thomas Lampert
 *
 *  This file is part of STDetect.
 *
 *  STDetect is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by the Free Software Foundation, 
 *  either version 3 of the License, or(at your option) any later version.
 *
 *  STDetect is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even 
 *  the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General 
 *  Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along with STDetect. If not, see 
 *  <http://www.gnu.org/licenses/>.  
 */


#include <mex.h>
#include <math.h>
#include <string.h>             /* Needed for memcpy() */
#include <time.h>	/* Added by AGT */

#define round(x) ((x)>=0?(int)((x)+0.5):(int)((x)-0.5))
#define PI 3.1415926535897932384626433832795

#define	SUCCESS			0
#define	MALLOCFAIL		-1
#define IMPROPERDIMS	-2

double *prelativeWindow;
double *pperrinEnergy;
int windowHeight, windowWidth;
double *harmonyNumber;
const unsigned int energyRows = 3;/* AGT Changed from int */
const unsigned int energyCols = 3;/* AGT Changed from int */
double *harmonicSet;
int windowOffset;

typedef struct snake{
	double *pos;
    int length;
}snake;

typedef struct spectrogram{
	double	*im;
    int dims[2];
}spectrogram;


/*********************************************************************************************************/
/*********************************************************************************************************/
/* The code for the external energy is not used, this is instead performed prior to entering this method */
/*********************************************************************************************************/
/*********************************************************************************************************/


/**********************************************************************************/
/* Check that neighbourhood is in the image (if not 20 is assigned to a location) */
/**********************************************************************************/

bool neighbourhoodInImage(double *pEimage){
    bool in = 1;
    unsigned int i, j; /* AGT Changed from int */
    for (i = 0; i < energyRows; i++){
        for (j = 0; j < energyCols; j++){
            in = in && (*(pEimage + i*energyCols + j) != 20);
        }
    }
    return(in);
}


/******************************************************************/
/* Check whether the snake position is within the specified range */
/******************************************************************/

bool snakeInRange(snake *input_snake, double *pRange, int forward){
    bool in = 1;
    int i;
    for (i = 0; i < input_snake->length; i++){
        in = in && ((forward == 1 && input_snake->pos[i] <= *(pRange+1)) || (forward == 0 && input_snake->pos[i] >= *(pRange+1)));
    }
    return in;
}


/***********************/
/* Invert a 2x2 Matrix */
/***********************/

void inv2x2Matrix(double *matrix, double *result){
    int i, j, count;
    
    double denom = ((-*(matrix + 1*2 + 0)) * *(matrix + 0*2 + 1)) + (*(matrix + 0*2 + 0) * *(matrix + 1*2 + 1));
    
    count = 3;
    for (i = 0; i < 2; i++){
       for (j = 0; j < 2; j++){
           if (i == j){
               *(result + i*2 + j) = *(matrix + count)/denom;
           }else{
               *(result + i*2 + j) = 0-(*(matrix + count)/denom);
           }
           count--;
       }
    }
}


/***********************************************/
/* Calculate harmonies possible in Spectrogram */
/***********************************************/
 
void harmonies(double *pHarm, double f, double mf){
    /*int upperLimit = floor(mf / f);*/
    int i;
    
    for (i = 0; i < ((int)*harmonyNumber); i++){
        double a = *(harmonicSet+i);
        double b=(f+1);
        
        pHarm[i] = (a * b) - 1;
    }
}


/*****************************************************************************/
/* Extract window from spectrogram and place in the pointer (pWindow) passed */
/*****************************************************************************/

void extractWindow(double *pWindow, spectrogram *input_spectrogram, int startx, int endx, int starty, int endy, int Isizey){
    int countx = -1;
    int county = -1, count = 0;
    int i, j;
    
    for (i = startx; i <= endx; i++){
        countx++;
        for(j = starty; j <= endy; j++){
            county++;
            count++;
            *(pWindow + countx * windowHeight + county) = input_spectrogram->im[i*input_spectrogram->dims[1] + j];
        }
        county = -1;
    }
}


/***************************************************************************************/
/* Multiply each element in the array specified in the pointer passed (parr) by weight */
/***************************************************************************************/

void multiplyArr(double *parr, double *pBlocked, double weight){
    unsigned int i, j; /* AGT Changed from int */
    
    for (i = 0; i < energyRows; i++){
        for (j = 0; j < energyCols; j++){
            if (*(pBlocked + j*energyCols + i) != 1){
                *(parr + i*energyCols + j) = *(parr + i*energyCols + j) * weight;
            }
        }
    }
}


/**************************************************************/
/* Normalise the array specified in the pointer passed (parr) */
/**************************************************************/

void normaliseArr(double *parr, double *pBlocked){
    double max = *(parr + energyCols + 1);
    unsigned int i, j;/* AGT Changed from int */
    
    for (i = 0; i < energyRows; i++){
        for (j = 0; j < energyCols; j++){
            if ((fabs(*(parr + i*energyCols + j)) > max) && (*(pBlocked + j*energyCols + i) != 1)){
                max = fabs(*(parr + i*energyCols + j));
            }
        }
    }
    
    for (i = 0; i < energyRows; i++){
        for (j = 0; j < energyCols; j++){
            if (*(pBlocked + j*energyCols + i) != 1){
                if (*(parr + i*energyCols + j) != 0){
                    *(parr + i*energyCols + j) = *(parr + i*energyCols + j) / max;
                }else{
                    *(parr + i*energyCols + j) = 0;
                }
            }
        }
    }
}


/************************************************************/
/* Calculate the Perrin energy for a particular snake point */
/************************************************************/

double intPerrin(snake *input_snake, int ind, double x, int y){
    
    double x1, x2, y1, y2, m_intersect, c_intersect, dx, dy, midx, midy, pm, pc, point1_1, point1_2, point2_1, point2_2;
    double angle[4];
    double m[4], c[4];
    double tan_phi, theta_2, theta_3, theta_4, mean_angle, c_BC, c_prime_1, c_prime_2, grad_BC, energy = 0;
    int i;
    
    if (ind > 1 && ind < input_snake->length-1){
        
        x1 = input_snake->pos[ind + 1];
        x2 = input_snake->pos[ind - 1];
        
        
        y1 = input_snake->pos[input_snake->length + ind + 1];
        y2 = input_snake->pos[input_snake->length + ind - 1];
        
        
        /* determine line which intersects both points */
        if((x2-x1) != 0){
            m_intersect = (y2 - y1)/(x2 - x1);
        }else{
            m_intersect = 99999999999999999999999999999999.9;
        }
        
        c_intersect = (-m_intersect * x1) + y1;
        
        /* determine mid point */
        dx = (x2-x1)/2;
        dy = (y2-y1)/2;
        
        midx = x1 + dx;
        midy = y1 + dy;
        
        /* determine perpendicular bisector */
        
        pm = -1 * (1/m_intersect);
        
        pc = (-pm * midx) + midy;
        
        
        for (i = -2; i < 2; i++){
            point1_1 = input_snake->pos[ind + i];
            point1_2 = input_snake->pos[input_snake->length + ind + i];
            point2_1 = input_snake->pos[ind + i + 1];
            point2_2 = input_snake->pos[input_snake->length + ind + i + 1];
            
            if (i == 0){
                point1_1 = input_snake->pos[ind + i] + x;
                point1_2 = input_snake->pos[input_snake->length + ind + i] + y;
            }
            /*point1 = [snake(ind+i, 1), snake(ind+i, 2)]
              point2 = [snake(ind+(i+1), 1), snake(ind+(i+1), 2)]*/
            
            if ((point2_1 - point1_1) != 0){
                m[i+2] = (point2_2 - point1_2)/(point2_1 - point1_1);
            }else{
                m[i+2] = 99999999999999999999999999999999.9;
            }
            
            c[i+2] = (-m[i+2] * point1_1) + point1_2;
        }
        
        /*  tan(alpha1) = m1 (meaning the tangent of the angle of intercept with
            the x axis is equal to the gradiant of the line)*/
        
        
        for (i = 0; i < 3; i++){
	    tan_phi = 0; /* AGT modified - assumed default value is 0. */
	    mean_angle = 0; /* AGT modified - safer to explicitly initialise to 0. */
            if (~mxIsInf(m[i]) && ~mxIsInf(m[i+1])){
                tan_phi = (m[i] - m[i+1]) / (1+(m[i] * m[i+1]));
            }else{
                if (~mxIsInf(m[i])){
                    if (m[i+1] >= 0){
                        tan_phi = 1/m[i+1];
                    }else{
                        tan_phi = -1/m[i+1];
                    }
                }else{
                    if (~mxIsInf(m[i+1])){
                        if (m[i] >= 0){
                            tan_phi = 1/m[i];
                        }else{
                            tan_phi = -1/m[i];
                        }
                    }
                }
            }
            angle[i] = atan(tan_phi * (PI / 180))  * (180 / PI);
            mean_angle = mean_angle + angle[i];
        }
        
        mean_angle = mean_angle / 3;
        
        /* point where perpendiclar bisector of BD = line with angle equal to
           the mean_angle with respect to CD
        
           need to determine the equation of the line with angle equal to mean_angle
           we know 1 point on this line, which is B on the snake
           the second point is the desired position of C (C')
           the gradiant must be related to the mean_angle (through pythagorus?) which we have derived
         
         Treating the lines x-axis, perpendicular bisector and desired CD line
         to be a triangle. We know the outside angle of BC to CD (mean_angle) 
         so the inside angle between BC and perpendicular bisector is theta_2
         (180-mean_angle)/2. Using the gradient of the perpendicular bisector 
         we can determine its angle with the x axis and the angle of the desired 
         line BC is 180 subtract these values. This then allows us to determine 
         the gradient and therefore the equation of this line. */
        
        theta_2 = (180 - mean_angle) / 2;
        theta_3 = 180 - (atan(pm * (PI / 180)) * (180 / PI));
        theta_4 = 180 - theta_3 - theta_2;
        
        grad_BC = tan(theta_4 * (PI / 180)) * (180 / PI);
        
        c_BC = (-grad_BC * input_snake->pos[ind - 1]) + input_snake->pos[input_snake->length + ind - 1];
        
        /*y = grad_BC * x + c_BC;*/
        
        /* Determine point of intersect between desired BC and perpendicular bisector */
        
        /* grad_BC * x + c_BC = pm * x + pc */
        
        c_prime_1 = (pc - c_BC) / (grad_BC - pm);
        c_prime_2 = grad_BC * c_prime_1 + c_BC;
        
        energy = sqrt(pow(((input_snake->pos[ind] + x) - c_prime_1), 2.0) + pow(((input_snake->pos[input_snake->length + ind] + y) - c_prime_2), 2.0));
    }
    
    return energy;
}


/********************************************/
/* Calculate the Internal Continuity energy */
/********************************************/

double intCont(snake *input_snake, int ind, double x, int y){
    double d = 0.0;
    
    if (ind == 0){
        d = sqrt(pow(((input_snake->pos[ind]+x) - input_snake->pos[ind+1]), 2.0) + pow(((input_snake->pos[input_snake->length+ind]+(double)y) - input_snake->pos[input_snake->length+ind+1]), 2.0));
    }
    else{
        d = sqrt(pow(((input_snake->pos[ind]+x) - input_snake->pos[ind-1]), 2.0) + pow(((input_snake->pos[input_snake->length+ind]+(double)y) - input_snake->pos[input_snake->length+ind-1]), 2.0));
    }

    return d;
}


/*******************************************/
/* Calculate the Internal Curvature energy */
/*******************************************/

double intCurv(snake *input_snake, int ind, double x, int y){
    double d = 0.0;
    double d1 = 0.0;
    double xi = 0.0;
    double xi1 = 0.0;
    double yi = 0.0;
    double yi1 = 0.0;
    double curve = 0.0;
    
    if (ind == 0){
        xi1 = (input_snake->pos[ind+1]) - (input_snake->pos[ind]+(x * *harmonyNumber));
        xi = xi1;
        
        yi1 = (input_snake->pos[input_snake->length + ind+1]) - (input_snake->pos[input_snake->length + ind]+y);
        yi = yi1;
        
        d1 = sqrt(pow(xi1, 2) + pow(yi1, 2));
        d = d1;
    }else{
        if (ind == input_snake->length-1){
            xi = (input_snake->pos[ind]+(x * *harmonyNumber)) - input_snake->pos[ind-1];
            xi1 = xi;
            
            yi = (input_snake->pos[input_snake->length + ind]+y) - input_snake->pos[input_snake->length + ind-1];
            yi1 = yi;
            
            d = sqrt(pow(xi, 2) + pow(yi, 2));
            d1 = d;
        }else{
            xi = (input_snake->pos[ind]+(x * *harmonyNumber)) - input_snake->pos[ind-1];
            yi = (input_snake->pos[input_snake->length + ind]+y) - input_snake->pos[input_snake->length + ind-1];
            
            xi1 = (input_snake->pos[ind+1]) - (input_snake->pos[ind]+(x * *harmonyNumber));
            yi1 = (input_snake->pos[input_snake->length + ind+1]) - (input_snake->pos[input_snake->length + ind]+y);
            
            d = sqrt(pow(xi, 2) + pow(yi, 2));
            d1 = sqrt(pow(xi1, 2) + pow(yi1, 2));
        }
    }
    
    curve = pow(((xi / d) - (xi1 / d1)), 2) + pow(((yi / d) - (yi1 / d1)), 2);

    return curve;
}


/*********************************************************************************************/
/* Sum the distance from each snake position and the position next to that (used by intCurv) */
/*********************************************************************************************/

double sumSnake(snake *input_snake, int ind){
    double sum = 0;
    
    sum = sum + fabs(input_snake->pos[ind+1] - input_snake->pos[+ind]);
    sum = sum + fabs(input_snake->pos[input_snake->length+ind+1] - input_snake->pos[input_snake->length+ind]);
    
    return sum;
}


/**************************/
/* Calculaes the walkrate */
/**************************/

double extWalkRate(double x, double c){
    return (x * -c);
}


/******************************************************************************************************************/
/* Sums the energies Econt, Ecurv and Eimage and places the result in the matrix specified by the pointer pEnergy */
/******************************************************************************************************************/

void addEnergies(double *pEnergy, double *pEcont, double *pEcurv, double *pImage, double *pEwalk){
    unsigned int i, j; /* AGT Changed from int */
    for (i = 0; i < energyRows; i++){
        for (j = 0; j < energyCols; j++){
            *(pEnergy + i*energyCols + j) = *(pEcont + i*energyCols + j) + *(pEcurv + i*energyCols + j) + *(pImage + i*energyCols + j) + *(pEwalk + i*energyCols + j);
        }
    }
}


/************************************************************************************************************************************/
/* Finds the locations of the minimum value in an array and places the column and row index in xpointer and ypointer (respectively) */
/************************************************************************************************************************************/

int findMinArr(double *pEnergy, double *pBlocked, int **xpointer, int **ypointer){
    double min =  *(pEnergy + 1*energyCols + 1);
    int counter = 1;
    unsigned int i, j; /* AGT Changed from int */
    
    for (i = 0; i < energyRows; i++){
        for (j = 0; j < energyCols; j++){
            if ((*(pEnergy + i*energyCols + j) < min) && (*(pBlocked + j*energyCols + i) != 1)){
                min = *(pEnergy + i*energyCols + j);
            }
        }
    }
    
    for (i = 0; i < energyRows; i++){
        for (j = 0; j < energyCols; j++){
            if ((*(pEnergy + i*energyCols + j) == min) && (*(pBlocked + j*energyCols + i) != 1)){
                if (counter != 1){
                    if ( (*xpointer = (int *) mxRealloc (*xpointer, counter * sizeof(int))) == NULL ){
                        mexWarnMsgTxt("Malloc failed...\n");

                        return MALLOCFAIL;
                    }
                    if ( (*ypointer = (int *) mxRealloc (*ypointer, counter * sizeof(int))) == NULL ){
                        mexWarnMsgTxt("Malloc failed...\n");

                        return MALLOCFAIL;
                    }
	            
                    
                }
                (*xpointer)[counter-1] = j;
                (*ypointer)[counter-1] = i;
                counter++;
            }
        }
    }
    
    return(counter-1);
}


/*********************************************************************/
/* Check all input and ouput valiables for the correct size and type */
/*********************************************************************/

void checkInputs(int nrhs, const mxArray *prhs[], int nlhs){
    
    if (nrhs != 17)
        mexErrMsgTxt("Must have sixteen arguments");
    
    if (nlhs != 1){
        mexErrMsgTxt("Must have one output argument");
    }
    
    if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || mxIsClass(prhs[0], "sparse") || mxIsChar(prhs[0])){
        mexErrMsgTxt("Input 1 must be real, full, and nonstring");
    }
    
    if (!mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]) || mxIsClass(prhs[1], "sparse") || mxIsChar(prhs[1])){
        mexErrMsgTxt("Input 2 must be integer, full, and nonstring");
    }
    if (mxGetN(prhs[1]) != 2 || mxGetM(prhs[1]) != 1){
        mexErrMsgTxt("Range must be a 1x2 vector");
    }
    
    if (!mxIsCell(prhs[2]) || mxIsComplex(prhs[2]) || mxIsClass(prhs[2], "sparse") || mxIsChar(prhs[2])){
        mexErrMsgTxt("Input 3 must be a structure");
    }
    
    if (!mxIsDouble(prhs[3]) || mxIsComplex(prhs[3]) || mxIsClass(prhs[3], "sparse") || mxIsChar(prhs[3])){
        mexErrMsgTxt("Input 4 must real, full, and nonstring");
    }
    
    if (!mxIsDouble(prhs[4]) || mxIsComplex(prhs[4]) || mxIsClass(prhs[4], "sparse") || mxIsChar(prhs[4])){
        mexErrMsgTxt("Input 5 must be real, full, and nonstring");
    }
    if (mxGetN(prhs[4]) !=  1 || mxGetM(prhs[4]) != 1){
        mexErrMsgTxt("Alpha must be a scalar");
    }
    
    if (!mxIsDouble(prhs[5]) || mxIsComplex(prhs[5]) || mxIsClass(prhs[5], "sparse") || mxIsChar(prhs[5])){
        mexErrMsgTxt("Input 6 must be real, full, and nonstring");
    }
    if (mxGetN(prhs[5]) !=  1 || mxGetM(prhs[5]) != 1){
        mexErrMsgTxt("Beta must be a scalar");
    }
    
    if (!mxIsDouble(prhs[6]) || mxIsComplex(prhs[6]) || mxIsClass(prhs[6], "sparse") || mxIsChar(prhs[6])){
        mexErrMsgTxt("Input 7 must be real, full, and nonstring");
    }
    if (mxGetN(prhs[6]) !=  1 || mxGetM(prhs[6]) != 1){
        mexErrMsgTxt("Gamma must be a scalar");
    }
    
    if (!mxIsDouble(prhs[7]) || mxIsComplex(prhs[7]) || mxIsClass(prhs[7], "sparse") || mxIsChar(prhs[7])){
        mexErrMsgTxt("Input 8 must be real, full, and nonstring");
    }
    if (mxGetN(prhs[7]) !=  1 || mxGetM(prhs[7]) != 1){
        mexErrMsgTxt("Correlation weight must be a scalar");
    }
    
    if (!mxIsDouble(prhs[8]) || mxIsComplex(prhs[8]) || mxIsClass(prhs[8], "sparse") || mxIsChar(prhs[8])){
        mexErrMsgTxt("Input 10 must be real, full, and nonstring");
    }
    if (mxGetN(prhs[8]) !=  energyCols || mxGetM(prhs[8]) != energyRows){
        mexErrMsgTxt("Blocked must be a 3x3 matrix");
    }
    
    if (!mxIsDouble(prhs[9]) || mxIsComplex(prhs[9]) || mxIsClass(prhs[9], "sparse") || mxIsChar(prhs[9])){
        mexErrMsgTxt("Input 11 must be real, full, and nonstring");
    }
    if (mxGetN(prhs[9]) !=  2){
        mexErrMsgTxt("Snake Positions must be a snakeLengthx2 matrix");
    }
    
    if (!mxIsDouble(prhs[10]) || mxIsComplex(prhs[10]) || mxIsClass(prhs[10], "sparse") || mxIsChar(prhs[10])){
        mexErrMsgTxt("Input 12 must be real, full, and nonstring");
    }
    if (mxGetN(prhs[11]) !=  (unsigned int)*mxGetPr(prhs[10])){ /* AGT Changed from int */
        mexErrMsgTxt("Number of elements in Harmonic Set must equal Harmony Number");
    }
    
    if (mxGetN(prhs[15]) !=  1 || mxGetM(prhs[15]) != 1){
        mexErrMsgTxt("Internal Energy must be a boolean");
    }
    
    if (mxGetN(prhs[16]) !=  1 || mxGetM(prhs[16]) != 1 || mxIsChar(prhs[16])  || mxIsClass(prhs[16], "sparse") || mxIsComplex(prhs[16])){
        mexErrMsgTxt("Window Offset must be an integer");
    }else{
        if (mxGetScalar(prhs[16])/floor(mxGetScalar(prhs[16])) != 1) {
            mexErrMsgTxt("Window Offset must be an integer");
        }
    }
}








int propagate_snake(spectrogram *input_spectrogram, snake *input_snake, double gamma, double alpha, double beta, double correlationWeight, double *pBlocked, double *pRange, double *pWalkrate, double *pinvGaussCov, double *pgaussMu, double *pgaussPCvec, double *poutputplot, int forward, double **hpointer){
    
    /* Create Energy matrices */
    double Econt[3][3], Ecurv[3][3], Energy[3][3], Eimage[3][3], Ewalkrate[3][3];
    bool moved = 1;
    int i, j, ind, y, x, ypos, xpos, hcount, *ypointer, *xpointer, count = 0, min_ind, x_trans;
    /* double gaussResponse; */ /* AGT changed - unused. */
    double *pwindow;
    
    pwindow = mxGetPr(mxCreateDoubleMatrix(windowHeight, windowWidth, mxREAL));
    
    /* initialise the random generator */
    srand((unsigned)time(NULL));
    
    /* START SNAKE ALGORITHM 
                           
     Keep repeating until the snake does not take 
     a move OR the snake moves out of the permitted 
     range OR a part of the energy neighbourhood 
     moves out of the image
   */   
     for (i = 0; i < 3; i++){
         for (j = 0; j < 3; j++){
             Eimage[i][j] = 0;
             Energy[i][j] = 0;
             Econt[i][j] = 0;
             Ecurv[i][j] = 0;
             Ewalkrate[i][j] = 0;
         }
     }
    
    /* setup dynamic array for storing the 'move to' positions */
    if ( (xpointer = (int *) mxMalloc(sizeof(int))) == NULL ){
        mexWarnMsgTxt("Malloc failed...\n");
        mxFree( xpointer );
        return MALLOCFAIL;
    }
    
    if ( (ypointer = (int *) mxMalloc(sizeof(int))) == NULL ){
        mexWarnMsgTxt("Malloc failed...\n");
        mxFree( xpointer );
        mxFree( ypointer );
        return MALLOCFAIL;
    }
    
     
     while (moved && neighbourhoodInImage(&Eimage[0][0]) && snakeInRange(input_snake, pRange, forward)){
         moved = 0;
        
         /* Repeat along the length of the snake */
         for (ind = 0; ind < input_snake->length; ind++){
             
             /******************************************************************/
             /* Calculate the harmonies of the current snake point's frequency */
             /******************************************************************/
             harmonies(*hpointer, input_snake->pos[ind], input_spectrogram->dims[1]);
             
             /* Reset energy matrices to 0 */
             for (i = 0; i < 3; i++){
                 for (j = 0; j < 3; j++){
                     Eimage[i][j] = 0;
                     Energy[i][j] = 0;
                     Econt[i][j] = 0;
                     Ecurv[i][j] = 0;
                     Ewalkrate[i][j] = 0;
                 }
             }
             
             /*********************************************************************/
             /* Loop through the energy neighbourhood for the current snake point */
             /*********************************************************************/
             for (y = 0; y < 1; y++){
                 ypos = y+1;
                 for (x = -1; x < 2; x++){
                     xpos = x+1;
                     x_trans = x * windowOffset;
                     
                     if (*(pBlocked + xpos*energyCols + ypos) == 0){
                         
                         /* check that the moving the snake to the position will not move it out of the image */
                         if (input_snake->pos[ind]+x_trans > 0 && input_snake->pos[ind]+((double)x_trans / *(harmonyNumber))+(windowWidth-1) < input_spectrogram->dims[1]){
                             
                             /***************************************************************************/
                             /* Calculate Eimage for the neighbourhood centred on each harmony position */
                             /***************************************************************************/
                             hcount = 0;
                             for (i = 0; i < (int)*harmonyNumber; i++){
                                 
                                 /* Check that the harmony frequency is within the image */
                                 if ((((*hpointer)[i] + x_trans + floor(windowWidth/2)) < input_spectrogram->dims[1]) && ((*hpointer)[i] != 0.0)){
                                     hcount++;
                                     
                                     /* Add the potential energy to the energy neighbourhood */
                                     switch (x){
                                         case 0:
                                             Eimage[ypos][xpos] = Eimage[ypos][xpos] + *(input_spectrogram->im + (int)(round((*hpointer)[i]+x_trans))*input_spectrogram->dims[0] + round(*(input_snake->pos + input_snake->length + ind)+y));
                                             break;
                                         case 1:
                                             Eimage[ypos][xpos] = Eimage[ypos][xpos] + *(input_spectrogram->im + (int)(round((*hpointer)[i]+x_trans))*input_spectrogram->dims[0] + round(*(input_snake->pos + input_snake->length + ind)+y));
                                             break;
                                         case -1:
                                             Eimage[ypos][xpos] = Eimage[ypos][xpos] + *(input_spectrogram->im + (int)(round((*hpointer)[i]+x_trans))*input_spectrogram->dims[0] + round(*(input_snake->pos + input_snake->length + ind)+y));
                                             break;
                                     }
                                 }
                             }
                             /*********************************************************/
                             /* Average energy results from fundemental and harmonies */
                             /*********************************************************/
                             if (hcount != 0){
                                 Eimage[ypos][xpos] = Eimage[ypos][xpos] / hcount;
                             }
                             
                             /*******************************/
                             /* Calculate Internal Energies */
                             /*******************************/
                             if ((int)*pperrinEnergy != 0){
                                 Econt[ypos][xpos] = 1;
                                 Ecurv[ypos][xpos] = intPerrin(input_snake, ind, ((double)x)/hcount, y);
                             }else{
                                 Econt[ypos][xpos] = intCont(input_snake, ind, ((double)x)/hcount, y);
                                 Ecurv[ypos][xpos] = intCurv(input_snake, ind, ((double)x)/hcount, y);
                             }
                             
                             /* Ewalkrate[ypos][xpos] = extWalkRate(((*hpointer)[i]+x), *pWalkrate); */
                             Ewalkrate[ypos][xpos] = extWalkRate(x, *pWalkrate);
                         }else{
                             /* if the neighbourhood position is outside of the image set the location to detectable number */
                             Eimage[ypos][xpos] = 20;
                         }
                     }
                 }
             }
             
             /*******************************/
             /* Normalise the energy arrays */
             /*******************************/
             normaliseArr(&Econt[0][0], pBlocked);
             normaliseArr(&Ecurv[0][0], pBlocked);
             normaliseArr(&Eimage[0][0], pBlocked);
             
             /******************************************/
             /* Multiply the energies by their weights */
             /******************************************/
             multiplyArr(&Eimage[0][0], pBlocked, gamma);
             multiplyArr(&Econt[0][0], pBlocked, alpha);
             multiplyArr(&Ecurv[0][0], pBlocked, beta);
             
             /************************************/
             /* Add all of the energies together */
             /************************************/
             addEnergies(&Energy[0][0], &Econt[0][0], &Ecurv[0][0], &Eimage[0][0], &Ewalkrate[0][0]);
             
             /*******************************************/
             /* Find minimum energy position to move to */
             /*******************************************/
             
             *xpointer = 0;
             *ypointer = 0;
             
             /* positions in the energy neighbourhood which contains the minimum (potential move to locations) */
             if( (count = findMinArr(&Energy[0][0], pBlocked, &xpointer, &ypointer)) == (double)MALLOCFAIL){
                 mxFree(xpointer);
                 mxFree(ypointer);
                 
                 return MALLOCFAIL;
             }
             
             /* if multiple energy neighbourhood locations are found to be minimum pick a random one */
             min_ind = (int) (count*rand()/(RAND_MAX+1.0));
             
             /* if all energy locations are equal OR there are none (error); move forward (i.e. on flat plateu) */
             if (count == 0){
                 y = 0;
                 x = 0;
             }else{
                 y = ypointer[min_ind] - 1;
                 x = xpointer[min_ind] - 1;
             }
             
             /************************************/
             /* Move snake point to new location */
             /************************************/
             input_snake->pos[ind] = input_snake->pos[ind] + ((double)x / *harmonyNumber);
             input_snake->pos[input_snake->length + ind] = input_snake->pos[input_snake->length + ind] + ((double)y / *harmonyNumber);
             
             moved = moved || !(y == 0 && x == 0);
             
             if (*poutputplot == 1.0){
                 mexEvalString("set(h2, 'XData', snakePos(:,1), 'YData', snakePos(:,2));");
             }
         }
     }
    
    mxFree(ypointer);
    mxFree(xpointer);
    
    return SUCCESS;
}



/*
 *  getData:  Gets data from a Matlab argument.
 *  Inputs: 
 *      const mxArray **prhs: Right hand side argument with RGB image
 *		(image *) Pointer to the black and white image struct.
 *
 *  Returns:
 *      int: 0 is successful run. -1 is a bad malloc. -2 is improper dims. 
 */
int getSnake( const mxArray **prhs, snake *input_snake )
{ 
    double      *pr; 
    int         number_of_dimensions, total_elements; 
    const mwSize   *ldims;/* AGT changed from int */
    
    if (mxIsNumeric(*prhs) == 0) 
        mexErrMsgTxt("Not numbers...\n");
    
    number_of_dimensions = mxGetNumberOfDimensions(*prhs);
    if( number_of_dimensions != 2 ){
        mexWarnMsgTxt("This input exceeds proper dimensions...\n");
        return IMPROPERDIMS;
    }
    
    total_elements = mxGetNumberOfElements(*prhs);
    ldims = mxGetDimensions(*prhs);
    input_snake->length = ldims[0];
    
    pr = (double *)mxGetData(*prhs);
    
    if (ldims[1] != 2){
        mexWarnMsgTxt("Wrong snake array size...\n");
		return IMPROPERDIMS;
    }
    
    
    /* Allocate the space */
	if ( (input_snake->pos = (double *)mxMalloc(sizeof(double) * total_elements)) == NULL ){
        mexWarnMsgTxt("snake malloc failed...\n");
        mxFree( input_snake->pos );
		return MALLOCFAIL;
	}

    /* Get the snake */
	memcpy(input_snake->pos, pr, sizeof(double) * total_elements);
    
    return SUCCESS;
}

int getSpectrogram( const mxArray **prhs, spectrogram *input_spectrogram ) { 
    double      *pr; 
    int         index, number_of_dimensions, total_elements; 
    const mwSize   *ldims;/* AGT changed from int */
    
    if (mxIsNumeric(*prhs) == 0) 
        mexErrMsgTxt("Not numbers...\n");
    
    number_of_dimensions = mxGetNumberOfDimensions(*prhs);
    if( number_of_dimensions != 2 ){
        mexWarnMsgTxt("This input exceeds proper dimensions...\n");
		return IMPROPERDIMS;
	}
    
    for (index=0; index<2; index++)
        input_spectrogram->dims[index]=0;
    
    total_elements = mxGetNumberOfElements(*prhs);
    ldims = mxGetDimensions(*prhs);
    for (index=0; index<number_of_dimensions; index++)
        input_spectrogram->dims[index] = ldims[index];
    
    pr = (double *)mxGetData(*prhs);
    
    /* Allocate the space */
	if ( (input_spectrogram->im = (double *)mxMalloc(sizeof(double) * total_elements)) == NULL ){
        mexWarnMsgTxt("im malloc failed...\n");
        mxFree(input_spectrogram->im);
		return MALLOCFAIL;
	}

    /* Get the spectrogram */
	memcpy(input_spectrogram->im, pr, sizeof(double) * total_elements);
    
    return SUCCESS;
}


int sendData( mxArray **plhs, snake *output_data )
{
    double *start_of_pr;   
    int bytes_to_copy, elements;
    mwSize dims[2];/* AGT changed from int */
    
    elements = output_data->length * 2;
    
    dims[0] = output_data->length;
    dims[1] = 2;
    
    /* Create a dims[0] by dims[1] by dims[2] array of unsigned 8-bit integers. */
    *plhs = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL); 
    
    /* Populate the the created array. */ 
    start_of_pr = (double *) mxGetData(*plhs);
    bytes_to_copy = ( elements ) * mxGetElementSize(*plhs);
    memcpy(start_of_pr, output_data->pos, bytes_to_copy);
    
    return SUCCESS;
} 


/******************************************************************************/
/******************************************************************************/
/*                           MAIN FUNCTION                                    */
/******************************************************************************/
/******************************************************************************/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
    
    /********************/
    /* Define Variables */
    /********************/
    
    spectrogram input_spectrogram;
    
    snake input_snake;
    
    /* Get weights to be applied to Energies */
                                                   /* alpha weight applied to Econt */
    double gamma, alpha, beta, correlationWeight;  /* beta weight applied to Ecurv */
                                                   /* gamma weight applied to Eimage */
                                                   /* Image intensity correlation weight */
    
    double *pBlocked, *pRange, *pWalkrate;         /* forward gradiant for snake */
                                                   /* range for snake to search in image */
                                                   /* Pointer to variable walkrates */
    
    int forward;
    
    double *hpointer, *pinvGaussCov, *pgaussMu, *pgaussPCvec, *poutputplot;
    
    double *pwindow;
    
    int status;
    
    mxArray *cell_element_ptr, *field_array_ptr;
    
    
    
    
    /********************/
    /* Check Input Data */
    /********************/
    
    checkInputs(nrhs, prhs, nlhs);
    
    
    /******************************/
    /* Initialise Input Variables */
    /******************************/
    
    if( (status = getSpectrogram( &prhs[0], &input_spectrogram )) != SUCCESS ){
        return;
    }
    
    /* Get weights to be applied to Energies */
    alpha = mxGetScalar(prhs[4]);             /* alpha weight applied to Econt */
    beta = mxGetScalar(prhs[5]);              /* beta weight applied to Ecurv */
    gamma = mxGetScalar(prhs[6]);             /* gamma weight applied to Eimage */
    correlationWeight = mxGetScalar(prhs[7]); /* Image intensity correlation weight */
    
    /* Get snake parameters */
    pBlocked = mxGetPr(prhs[8]);              /* Neighbourhood positions that the snake points are allowed to move to */
    pRange = mxGetPr(prhs[1]);                /* range for snake to search in image */
    pWalkrate = mxGetPr(prhs[3]);             /* Pointer to variable walkrates */
     
     if (*pRange < *(pRange + 1)){
         forward = 1;
     }else{
         forward = 0;
     }
     
     /* Retrieve data passed in the Net cell array from Matlab */
     cell_element_ptr = mxGetCell(prhs[2], 1);
     
     field_array_ptr = mxGetField(cell_element_ptr, 0, "width");
     windowWidth = (int)*mxGetPr(field_array_ptr);
     
     field_array_ptr = mxGetField(cell_element_ptr, 0, "height");
     windowHeight = (int)*mxGetPr(field_array_ptr);
     
     pgaussMu = mxGetPr(mxGetCell(mxGetField(cell_element_ptr, 0, "mu"), 0));
     
     pinvGaussCov = mxGetPr(prhs[12]);
     
     pgaussPCvec = mxGetPr(mxGetField(cell_element_ptr, 0, "pcvec"));
     
     pwindow = mxGetPr(mxCreateDoubleMatrix(windowHeight, windowWidth, mxREAL));
     
     if( (status = getSnake( &prhs[9], &input_snake )) != SUCCESS ){
         mxFree( input_spectrogram.im );
         return;
     }
     
     harmonyNumber = mxGetPr(prhs[10]);
     
     if ( (hpointer = (double *) mxMalloc((unsigned int)((*(harmonyNumber) + 1)) * sizeof(double))) == NULL ){
        mexWarnMsgTxt("Harmony malloc failed...\n");
        mxFree( hpointer );
        mxFree( input_spectrogram.im );
        mxFree( input_snake.pos );
		return;
	}
     
     harmonicSet = mxGetPr(prhs[11]);
     
     poutputplot = mxGetPr(prhs[13]);
     
     prelativeWindow = mxGetPr(prhs[14]);
     
     pperrinEnergy = mxGetPr(prhs[15]);
     
     windowOffset  = (int)mxGetScalar(prhs[16]);
     
     /*************************/
     /* Start Snake Algorithm */
     /*************************/
    status = propagate_snake(&input_spectrogram, &input_snake,
                gamma, alpha, beta, correlationWeight, pBlocked, pRange, pWalkrate, 
                    pinvGaussCov, pgaussMu, pgaussPCvec, poutputplot, forward, &hpointer);
     if (status != SUCCESS ){
         if(status == MALLOCFAIL){
             mxFree( hpointer );
             mxFree( input_spectrogram.im );
             mxFree( input_snake.pos );
             return;
         }
     }
     
     /*
     for(i = 0; i < input_snake.length*2; i++){
        input_snake.pos[i] = 131.0;
        *((char *) input_snake.pos[i]) = 0x4;
     }
     
     printf("**%d\n", sizeof(double));
     printf("*%f\n", input_snake.pos[0]);
     *((char *) input_snake.pos) = *((char *) input_snake.pos) & 0xfb;
     *((char *) input_snake.pos) = 0x4;
     
     for (i = 0; i < 8; i++) {
       printf("%x\n", ((char *) input_snake.pos)[i]);
     }
      *
     printf("*%f\n", input_snake.pos[0]);
     for (i = 0; i < 8; i++) {
       printf("%x\n", ((char *) input_snake.pos)[i]);
     }
      */
     
     /**********************************/
     /* Copy Result to Output Variable */
     /**********************************/
     sendData( &plhs[0], &input_snake );
     
     
     mxFree( hpointer );
     mxFree( input_snake.pos );
     mxFree( input_spectrogram.im );
     
     return;
}
