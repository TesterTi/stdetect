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

#define	SUCCESS			0
#define	MALLOCFAIL		-1
#define IMPROPERDIMS	-2

int NDIMS = 0;

typedef struct image{
	double	*im;
    int dims[2];
}image;

typedef struct threed{
	double	*data;
    mwSize dims[3]; /* Changed by AGT from int to mwSize */
}threed;


int	pca_convolution( image *input_im, int window_Height, int window_Width, double *templates_ptr, threed *output);
int getData( const mxArray **prhs, image *bw_im );
int getTemplates( const mxArray **prhs, threed *filters );
int sendData( mxArray **plhs, threed *ed_im );

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
	image	input_im;
    threed  output;
	int		status;
    mxArray *cell_element_ptr;
    double  *templates_ptr;
    int     window_Width, window_Height;
    const mwSize  *dim_array; /* Modified by AGT, int changed to mwSize */
    
  	/* requires two variables, the image and the filters. */
    if( nrhs == 2 ){
		if( (status = getData( &prhs[0], &input_im )) != SUCCESS ){
			return;
		}
	} else {
        mexErrMsgTxt("No Input...\n");
	}
    
    if ( (cell_element_ptr = mxGetCell(prhs[1], 0)) == NULL){
        return;
    }
    if ( (templates_ptr = mxGetPr(cell_element_ptr)) == NULL){
        return;
    }
    
    if (mxGetNumberOfDimensions(mxGetCell(prhs[1], 0)) != 3 && mxGetNumberOfDimensions(mxGetCell(prhs[1], 0)) != 2){
        return;
    }else 
        dim_array = mxGetDimensions(mxGetCell(prhs[1], 0));
        if (mxGetNumberOfDimensions(mxGetCell(prhs[1], 0)) == 3){
        NDIMS = dim_array[2];
    }else{
        NDIMS = 1;
    }
    
    if ( (cell_element_ptr = mxGetCell(prhs[1], 1)) == NULL){
        return;
    }
    window_Width = (int)*mxGetPr(cell_element_ptr);
    
    if ( (cell_element_ptr = mxGetCell(prhs[1], 2)) == NULL){
        return;
    }
    window_Height = (int)*mxGetPr(cell_element_ptr);
    
    /* Run the pca convolution algorithm */
	if( (status = pca_convolution(&input_im, window_Height, window_Width, templates_ptr, &output)) != SUCCESS ){
		if(status == MALLOCFAIL)
			mxFree( input_im.im );
		return;
	}
    
    /* Send the edged image back to Matlab. */
    sendData( &plhs[0], &output);
    
    mxFree( input_im.im );
    mxFree( output.data );
    
    return;
}

/*
 *  pca_convolution:  Converts the BW image into a line detected image.
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
int pca_convolution( image *input_im, int window_Height, int window_Width, double *templates_ptr, threed *output )
{
    mwSize     X, Y;/* AGT modified, was int */
    int I, J, s, elements, im_offset, filter_offset;
    double *SUM;
    
    if ( (SUM = (double *)mxMalloc(sizeof(double) * NDIMS)) == NULL){
        mexWarnMsgTxt("Malloc failed...\n");
        mxFree( SUM );
		return MALLOCFAIL;
    }
    
    elements = input_im->dims[0] * input_im->dims[1] * NDIMS;
	output->dims[0] = input_im->dims[0];
	output->dims[1] = input_im->dims[1];
    output->dims[2] = NDIMS;
	
	if ( (output->data = (double *)mxMalloc(sizeof(double) * elements)) == NULL){
        mexWarnMsgTxt("Edge im malloc failed...\n");
		return MALLOCFAIL;
    }
    
    
     /* Convolution starts here */
    for(Y=0; Y<output->dims[0]; Y++)  {
        for(X=0; X<output->dims[1]; X++)  {
            
            for(s=0;s<NDIMS;s++){
                SUM[s] = 0;
            }
            
            /* image boundaries */
            /* AGT modified the casts from int to mwSize - issue is if window_Width-1 is less than 0 */
            if( X<(mwSize)((window_Width-1) / 2) || X>=(output->dims[1] - ((int)((window_Width-1) / 2)))){ /*rows*/
            } else if( Y<(mwSize)((window_Height-1) / 2) || Y>=(output->dims[0] - (int)((window_Height-1) / 2))) { /*cols*/
            /* Convolution starts here */
            } else {
                for(I=-(int)((window_Height-1) / 2); I<=(int)((window_Height-1) / 2); I++)  {
                    for(J=-(int)((window_Width-1) / 2); J<=(int)((window_Width-1) / 2); J++)  {
                        
                        im_offset = (X+J)*output->dims[0] + (Y+I);
                        filter_offset = (J+((int)((window_Width-1) / 2)))*(window_Height) + (I+(int)((window_Height-1) / 2));
                        
                        for(s=0;s<NDIMS;s++){
                            SUM[s] += (*(input_im->im+im_offset)) * 
                                      (*(templates_ptr + (filter_offset + (s*window_Height*window_Width))));
                        }
                    }
                }
            }
            
            for(s=0;s<NDIMS;s++){
                output->data[(X*output->dims[0] + Y) + s*(output->dims[0]*output->dims[1])] = SUM[s];
            }
        }
    }
   
    mxFree(SUM);
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
    const mwSize   *ldims; /* AGT modified from int to mwSize. */
    
     if (mxIsNumeric(*prhs) == 0) 
		mexErrMsgTxt("Not numbers...\n");
    
    number_of_dimensions = mxGetNumberOfDimensions(*prhs);
    if( number_of_dimensions != 2 ){
        mexWarnMsgTxt("This input exceeds proper dimensions...\n");
		return IMPROPERDIMS;
	}
    
    for (index=0; index<2; index++)
        bw_im->dims[index]=0;
    
    total_elements = mxGetNumberOfElements(*prhs);
    ldims = mxGetDimensions(*prhs);
    for (index=0; index<number_of_dimensions; index++)
        bw_im->dims[index] = ldims[index];
    
    pr = (double *)mxGetData(*prhs);
    
    /* Allocated the space */
	if ( (bw_im->im = (double *)mxMalloc(sizeof(double) * total_elements)) == NULL ){
        mexWarnMsgTxt("im malloc failed...\n");
		return MALLOCFAIL;
	}

    /* Get the image */
	memcpy(bw_im->im, pr, sizeof(double) * total_elements);
    
    return SUCCESS;
}

/*
 *  sendData:  Sends data back to a Matlab argument.
 *  Inputs: 
 *      mxArray **plhs: Left hand side argument to get edge detected image
 *      (image *) Image to go back to Matlab.
 */
int sendData( mxArray **plhs, threed *output_data )
{
    double *start_of_pr;   
    int bytes_to_copy, elements;
    
    elements = output_data->dims[0] * output_data->dims[1] * output_data->dims[2];
    
    /* Create a dims[0] by dims[1] by dims[2] array of unsigned 8-bit integers. */
    *plhs = mxCreateNumericArray(3,output_data->dims,mxDOUBLE_CLASS,mxREAL); 
    
    /* Populate the the created array. */ 
    start_of_pr = (double *) mxGetData(*plhs);
    bytes_to_copy = ( elements ) * mxGetElementSize(*plhs);
    memcpy(start_of_pr, output_data->data, bytes_to_copy);
    
    return SUCCESS;
} 

