/*	bar_convolution.c
 *	Examples:
 *      line_image = bar_convolution(bw_im);		
 *		
 *  Notes:
 *      Takes a DOUBLE image (Max of 255)
 *      This takes a Black and White image and produces a line image.
 *
 *  To Build:
 *      mex -v bar_convolution.c
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

#define NDIMS           2       /*X * Y*/

#define	SUCCESS			0
#define	MALLOCFAIL		-1
#define IMPROPERDIMS	-2

typedef struct image{
	double	*im;
	int     dims[NDIMS];
}image;

int	bar_convolution( image *bw_im, int bar_Length, double *templates_ptr, double *pixel_count_ptr, image *ed_im );
int getData( const mxArray **prhs, image *bw_im );
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
	image	bw_im, ed_im;
	int		status;
    mxArray *cell_element_ptr;
    double *templates_ptr, *pixel_count_ptr;
    int bar_length;
    
  	/*requires one variable, the image.*/
    if( nrhs == 2 ){
		if( (status = getData( &prhs[0], &bw_im )) != SUCCESS ){
			return;
		}
	} else {
        mexErrMsgTxt("No Input...\n");
	}
    
    if ( (cell_element_ptr = mxGetCell(prhs[1], 0)) == NULL){
        return;
    }
    
    bar_length = (int)*mxGetPr(cell_element_ptr);
    
    if ( (cell_element_ptr = mxGetCell(prhs[1], 3)) == NULL){
        return;
    }
    
    if ( (templates_ptr = mxGetPr(cell_element_ptr)) == NULL){
        return;
    }
    
    if ( (cell_element_ptr = mxGetCell(prhs[1], 4)) == NULL){
        return;
    }
    if ( (pixel_count_ptr = mxGetPr(cell_element_ptr)) == NULL){
        return;
    }
    
    /*Run the bar convolution algorithm*/
	if( (status = bar_convolution(&bw_im, bar_length, templates_ptr, pixel_count_ptr, &ed_im )) != SUCCESS ){
		if(status == MALLOCFAIL)
			free( bw_im.im );
		return;
	}
    
    /*Send the edged image back to Matlab.*/
    sendData( &plhs[0], &ed_im);
    
    free( bw_im.im );
    free( ed_im.im );
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
int bar_convolution( image *bw_im, int bar_Length, double *templates_ptr, double *pixel_count_ptr, image *ed_im )
{
    int     X, Y, I, J, elements, im_offset, mask_offset, r;
    double SUM, MAXIMUM;
    
    elements = bw_im->dims[0] * bw_im->dims[1];
	ed_im->dims[0] = bw_im->dims[0];
	ed_im->dims[1] = bw_im->dims[1];
    
	if ( (ed_im->im = malloc(sizeof(double) * elements)) == NULL ){
        mexWarnMsgTxt("Edge im malloc failed...\n");
		return MALLOCFAIL;
	}
     /* Convolution starts here*/
    for(Y=0; Y<ed_im->dims[1]; Y++)  {
        for(X=0; X<ed_im->dims[0]; X++)  {
            /* image boundaries */
            if( Y<bar_Length-1 || Y==ed_im->dims[1]){ /*rows*/
                MAXIMUM = 0;
            } else if( X<bar_Length-1 || X==ed_im->dims[0]) { /*cols*/
                MAXIMUM = 0;
            /* Convolution starts here*/
            } else {
                MAXIMUM = 0;
                
                for(r=0; r<32; r++){
                    SUM = 0;
                    for(I=-(bar_Length-1); I<=0; I++)  {
                        for(J=-(bar_Length-1); J<=0; J++)  {
                            
                            im_offset = (Y+J)*ed_im->dims[0] + (X+I);
                            
                            /*mask_offset = (I+1)+((J+1)*bar_Length);*/
                            mask_offset = (I+(bar_Length-1)) + ((J+(bar_Length-1))*bar_Length) + (r*bar_Length*bar_Length);
                            
                            /*printf("image: %f\n", (*(bw_im->im+im_offset)));*/
                            /*printf("template: %f\n", *(templates_ptr + mask_offset));*/
                            
                            SUM += 
                                (*(bw_im->im+im_offset)) * 
                                (*(templates_ptr + mask_offset));
                        }
                    }
                    
                    SUM = fabs(SUM) / *(pixel_count_ptr + r);
                    /*printf("SUM: %f\n", SUM);*/
                    if(SUM == 0){
                        MAXIMUM = SUM;
                    }else{
                        if(SUM > MAXIMUM){
                            MAXIMUM = SUM;
                        }
                    }
                }
             }
             
			 if(MAXIMUM > 255)	MAXIMUM = 255;
			 else if(MAXIMUM < 0)	MAXIMUM = 0;
            *(ed_im->im+Y*ed_im->dims[0]+X) = 255 - MAXIMUM;  
	     
        }
    }
   
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
int getData( const mxArray **prhs, image *bw_im )
{ 
    double      *pr; 
    int         index, number_of_dimensions, total_elements; 
    const int   *ldims;
    
     if (mxIsNumeric(*prhs) == 0) 
		mexErrMsgTxt("Not numbers...\n");
    
    for (index=0; index<NDIMS; index++)
        bw_im->dims[index]=0;
    
    total_elements = mxGetNumberOfElements(*prhs);
    number_of_dimensions = mxGetNumberOfDimensions(*prhs);
    ldims = mxGetDimensions(*prhs);
    for (index=0; index<number_of_dimensions; index++)
        bw_im->dims[index] = ldims[index];
    
    pr = (double *)mxGetData(*prhs);
    
	if( number_of_dimensions > NDIMS ){
        mexWarnMsgTxt("This input exceeds proper dimensions...\n");
		return IMPROPERDIMS;
	}
    
    /*Allocated the space*/
	if ( (bw_im->im = malloc(sizeof(double) * total_elements)) == NULL ){
        mexWarnMsgTxt("im malloc failed...\n");
		return MALLOCFAIL;
	}

    /*Get the image*/
	memcpy(bw_im->im, pr, sizeof(double) * total_elements);
    
    return SUCCESS;
}

/*
 *  sendData:  Sends data back to a Matlab argument.
 *  Inputs: 
 *      mxArray **plhs: Left hand side argument to get edge detected image
 *      (image *) Image to go back to Matlab.
 */
int sendData( mxArray **plhs, image *ed_im )
{
    double *start_of_pr;   
    int bytes_to_copy, elements;

    elements = ed_im->dims[0] * ed_im->dims[1];
   
    /* Create a dims[0] by dims[1] array of unsigned 8-bit integers. */
    *plhs = mxCreateNumericArray(NDIMS,ed_im->dims,mxDOUBLE_CLASS,mxREAL); 
                                  
    /* Populate the the created array. */
    start_of_pr = (double *) mxGetData(*plhs);
    bytes_to_copy = ( elements ) * mxGetElementSize(*plhs);
    memcpy(start_of_pr, ed_im->im, bytes_to_copy);
  
    return SUCCESS;
} 

