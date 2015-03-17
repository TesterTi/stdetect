/*	pca_gaussian.c
 *	Examples:
 *      line_image = pca_gaussian(bw_im);		
 *		
 *  Notes:
 *      Takes a DOUBLE image (Max of 255)
 *      This takes a Black and White image and produces a line image.
 *
 *  To Build:
 *      mex -v pca_gaussian.c
 *
 *	Author:
 *		Anthony Gabrielson edited from sobel detector to line convolution by Thomas Lampert
 *		agabriel@home.tzo.org
 *      18/09/08
 */

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
#include <string.h>             /* Needed for memcpy() */
#include <math.h>

#define	SUCCESS			0
#define	MALLOCFAIL		-1
#define IMPROPERDIMS	-2
#define PI 3.1415926535897932384626433832795

mwSize D = 0;/* AGT changed from int */

typedef struct image{
	double	*im;
	mwSize     dims[2];/* AGT changed from int */
}image;

typedef struct threed{
	double	*data;
	mwSize     dims[3];/* AGT changed from int */
}threed;

typedef struct gaussian{
	double	*mu;
	double  *sig;
    mwSize     dims;/* AGT changed from int */
}gaussian;

int	pca_gaussian( threed *pca_im, gaussian *gauss, int window_Width, int window_Height, image *ed_im);
double gauss_response(double *vector_ptr, gaussian *gauss);
void matrixM(double *m1, double *m2, double *result, int d1, int d2, int d3, int d4);
double matrixDeterminant2x2(double *matrix);
void squareDiagonalMatrix(double *matrix, int d);
void invertDiagonalMatrix(double *matrix, int d);
int getData( const mxArray **prhs, threed *bw_im );
int getGaussData( const mxArray **prhs, gaussian *gauss );
int sendData( mxArray **plhs, image *ed_im );

/*
 *  mexFunction:  Matlab entry function into this C code
 *  Inputs: 
 *      int nlhs:   Number of left hand arguments (output)
 *      mxArray *plhs[]:   The left hand arguments (output)
 *      int nrhs:   Number of right hand arguments (inputs)
 *      const mxArray *prhs[]:   The right hand arguments (inputs)
 *
 * Notes:
 *      (Left)  goes_out = foo(goes_in);    (Right)
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	image	 output_im;
    threed   pca_data;
    gaussian gauss;
	int		 status;
    mxArray  *cell_element_ptr;
    int      window_Width, window_Height;
    
    /*requires three variables, the 3D filtered image block, the gaussian distribution and the filter's size.*/
    if( nrhs == 3 ){
        if( (status = getData( &prhs[0], &pca_data )) != SUCCESS ){
			return;
		}
        if( (status = getGaussData( &prhs[1], &gauss )) != SUCCESS ){
			return;
		}
        
        if ( (cell_element_ptr = mxGetCell(prhs[2], 0)) == NULL){
            return;
        }
        if (mxGetNumberOfDimensions(cell_element_ptr) != 3 && mxGetNumberOfDimensions(cell_element_ptr) != 2){
            return;
        }
        if (!mxIsNumeric(cell_element_ptr)){
            return;
        }
        
        if ( (cell_element_ptr = mxGetCell(prhs[2], 1)) == NULL){
            return;
        }
        window_Height = (int)*mxGetPr(cell_element_ptr);
        
        if ( (cell_element_ptr = mxGetCell(prhs[2], 2)) == NULL){
            return;
        }
        window_Width = (int)*mxGetPr(cell_element_ptr);
        
	} else {
        mexErrMsgTxt("Incorrect Input...\n");
	}
    
    /*Run the pca convolution algorithm*/
	if( (status = pca_gaussian(&pca_data, &gauss, window_Height, window_Width, &output_im)) != SUCCESS ){
		if(status == MALLOCFAIL){
			mxFree( pca_data.data );
            mxFree( gauss.mu );
            mxFree( gauss.sig );
            mxFree( output_im.im );
        }
		return;
	}
    
    
    
    /*Send the response image back to Matlab.*/
    sendData( &plhs[0], &output_im);
    
    mxFree( pca_data.data );
    mxFree( output_im.im );
    mxFree( gauss.mu );
    mxFree( gauss.sig );
    
    return;
}

/*
 *  bar_convolution:  Converts the BW image into a line detected image.
 *  Inputs: 
 *      (image *) Org Black and White image struct.
 *		(image *) The line detected image struct.
 *
 *  Returns:
 *      int: 0 is successful run. -1 is a bad malloc.
 *
 *  How this algorithm works:
 *      http://www.pages.drexel.edu/~weg22/edge.html
 */
int pca_gaussian( threed *pca_data, gaussian *gauss, int window_Width, int window_Height, image *output_im )
{
    int    X, Y, elements, im_offset;
    mwSize Z; /* AGT changed from int */
    double SUM;
    double *vector;
    
    if ( (vector = (double *)mxMalloc(sizeof(double) * D)) == NULL){
        mexWarnMsgTxt("Malloc failed...\n");
        mxFree( vector );
		return MALLOCFAIL;
    }
    
    squareDiagonalMatrix(gauss->sig, gauss->dims);
    invertDiagonalMatrix(gauss->sig, gauss->dims);
    
    elements = pca_data->dims[0] * pca_data->dims[1];
	output_im->dims[0] = pca_data->dims[0];
	output_im->dims[1] = pca_data->dims[1];

	if ( (output_im->im = (double *)mxMalloc(sizeof(double) * elements)) == NULL){
        mexWarnMsgTxt("Output im malloc failed...\n");
		return MALLOCFAIL;
	}
    
     /* Convolution starts here */
    for(Y=0; Y<output_im->dims[0]; Y++)  {
        for(X=0; X<output_im->dims[1]; X++)  {
            
            im_offset = X*pca_data->dims[0] + Y;
            
            /* image boundaries */
            if( X<(int)((window_Width-1) / 2) || X>=(output_im->dims[1] - ((int)((window_Width-1) / 2)))){ /*rows*/
                SUM = 1;
            } else if( Y<(int)((window_Height-1) / 2) || Y>=(output_im->dims[0] - (int)((window_Height-1) / 2))) { /*cols*/
                SUM = 1;
            /* Computation starts here */
            } else {
                
                for (Z=0; Z<D; Z++){
                    vector[Z] = *(pca_data->data + im_offset + Z*(pca_data->dims[1]*pca_data->dims[0]));
                }
                
                SUM = gauss_response( &vector[0], gauss );
            }
            
            output_im->im[im_offset] = SUM;
        }

    }
   
    mxFree(vector);
    
	return SUCCESS;
}

double gauss_response(double *vector_ptr, gaussian *gauss){
    double *r, t;
    mwSize i;/* AGT changed from int */
    
    if ( (r = (double *)mxMalloc(sizeof(double) * D)) == NULL){
        mexWarnMsgTxt("Malloc failed...\n");
        mxFree( r );
		return MALLOCFAIL;
    }
    
    for (i = 0; i < D; i++){
        r[i] = 0;
    }
    
    /*if ((int)*prelativeWindow != 0){
        subtractFromMatrix(x, min);
    }*/
    
    for (i = 0; i < gauss->dims; i++){
        *(vector_ptr + i) = *(vector_ptr + i) - *(gauss->mu + i);
    }
    
    matrixM(vector_ptr, gauss->sig, &r[0], 1, gauss->dims, gauss->dims, gauss->dims);
    
    matrixM(&r[0], vector_ptr, &t, 1, gauss->dims, gauss->dims, 1);
    
    mxFree(r);
    
    return exp((-0.5) * t);
}

/*******************/
/* Matrix Multiply */
/*******************/
void matrixM(double *m1, double *m2, double *result, int d1, int d2, int d3, int d4){
    int i, j;
    
    for (i = 0; i < d4; i++){
        *(result + i) = 0;
        for (j = 0; j < d3; j++){
            *(result + i) = *(result + i) + (*(m1 + j) * *(m2 + i*d3 + j));
        }
    }
}

double matrixDeterminant2x2(double *matrix){
    return (*(matrix+0) * *(matrix+3)) - (*matrix+1 * *matrix+2);
}

void squareDiagonalMatrix(double *matrix, int d){
    int i;
    
    for (i = 0; i < d; i++){
        *(matrix + (i * (d+1))) = *(matrix + (i * (d+1))) * *(matrix + (i * (d+1)));
    }
}

void invertDiagonalMatrix(double *matrix, int d){
    int i;
    
    for (i = 0; i < d; i++){
        *(matrix + (i * (d+1))) = 1 / *(matrix + (i * (d+1)));
    }
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
int getData( const mxArray **prhs, threed *input_data )
{ 
    double      *pr;
    int         index, number_of_dimensions, total_elements;
    const mwSize   *ldims; /* AGT changed from int to mwSize */
    
    if (mxIsNumeric(*prhs) == 0)
		mexErrMsgTxt("Not numbers...\n");
    
    number_of_dimensions = mxGetNumberOfDimensions(*prhs);
    
    if( number_of_dimensions != 3 && number_of_dimensions != 2 ){
        mexWarnMsgTxt("This input exceeds proper dimensions...\n");
		return IMPROPERDIMS;
	}

    for (index=0; index<number_of_dimensions; index++)
        input_data->dims[index]=0;
    
    if (number_of_dimensions == 2)
        input_data->dims[2] = 1;
    
    total_elements = mxGetNumberOfElements(*prhs);
    
    ldims = mxGetDimensions(*prhs);
    for (index=0; index<number_of_dimensions; index++){
        input_data->dims[index] = ldims[index];
    }
    D = input_data->dims[2];
    
    pr = (double *)mxGetData(*prhs);
    
    /* Allocated the space */
	if ( (input_data->data = (double *)mxMalloc(sizeof(double) * total_elements)) == NULL ){
        mexWarnMsgTxt("im malloc failed...\n");
		return MALLOCFAIL;
	}

    /*Get the image */
	memcpy(input_data->data, pr, sizeof(double) * total_elements);
    
    return SUCCESS;
}

int getGaussData( const mxArray **prhs, gaussian *gauss )
{ 
    double      *pr; 
    int         number_of_dimensions, total_elements; 
    const mwSize   *ldims;/* AGT changed to mwSize from int */
    mxArray     *cell_element_ptr;
    
    if ( (cell_element_ptr = mxGetCell(*prhs, 0)) == NULL){
        return MALLOCFAIL;
    }
    
    if (mxIsNumeric(cell_element_ptr) == 0) 
		mexErrMsgTxt("Not numbers...\n");
    
    total_elements = mxGetNumberOfElements(cell_element_ptr);
    number_of_dimensions = mxGetNumberOfDimensions(cell_element_ptr);

    ldims = mxGetDimensions(cell_element_ptr);
    if (ldims[0] != 1)
        mexErrMsgTxt("Mu should be a 1xD vector!\n");
    
    if(ldims[1] != D)
        mexErrMsgTxt("Gaussian and data dimensions do not match!");
    
    gauss->dims = ldims[1];
    
    pr = (double *)mxGetData(cell_element_ptr);
    
    /*Allocated the space*/
	if ( (gauss->mu = (double *)mxMalloc(sizeof(double) * total_elements)) == NULL ){
        mexWarnMsgTxt("im malloc failed...\n");
		return MALLOCFAIL;
	}
    
    /*Get the mean*/
	memcpy(gauss->mu, pr, sizeof(double) * total_elements);
    
    
    
    if ( (cell_element_ptr = mxGetCell(*prhs, 1)) == NULL){
        return MALLOCFAIL;
    }
    
    if (mxIsNumeric(cell_element_ptr) == 0) 
		mexErrMsgTxt("Not numbers...\n");
    
    
    total_elements = mxGetNumberOfElements(cell_element_ptr);
    number_of_dimensions = mxGetNumberOfDimensions(cell_element_ptr);
    ldims = mxGetDimensions(cell_element_ptr);
    if (ldims[0] != ldims[1] && gauss->dims != ldims[0])
        mexErrMsgTxt("Wrong Covariance Size...\n");
    
    pr = (double *)mxGetData(cell_element_ptr);
    
    /*Allocated the space*/
	if ( (gauss->sig = (double *)mxMalloc(sizeof(double) * total_elements)) == NULL ){
        mexWarnMsgTxt("im malloc failed...\n");
		return MALLOCFAIL;
	}

    /*Get the covariance matrix*/
	memcpy(gauss->sig, pr, sizeof(double) * total_elements);
    
    return SUCCESS;
}

/*
 *  sendData:  Sends data back to a Matlab argument.
 *  Inputs: 
 *      mxArray **plhs: Left hand side argument to get edge detected image
 *      (image *) Image to go back to Matlab.
 */
int sendData( mxArray **plhs, image *output_im )
{
    double *start_of_pr;
    int bytes_to_copy, elements;
    
    elements = output_im->dims[0] * output_im->dims[1];
    
    /* Create a dims[0] by dims[1] array of unsigned 8-bit integers. */
    *plhs = mxCreateNumericArray(2, output_im->dims, mxDOUBLE_CLASS, mxREAL);
    
    /* Populate the the created array. */
    start_of_pr = (double *) mxGetData(*plhs);
    bytes_to_copy = ( elements ) * mxGetElementSize(*plhs);
    memcpy(start_of_pr, output_im->im, bytes_to_copy);
    
    return SUCCESS;
}
