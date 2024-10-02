/* This function generates a LIC image using Fast LIC method and a given kernel filter */

#include "math.h"
#include "float.h"
#include "mex.h"   /* --This one is required */

struct TPoint{
    int x,y;
};


int maximumOf(int a, int b)
{
    if (a > b) {
        return a;
    }
    else
      return b;
}

int minimumOf(int a, int b)
{
    if (a < b) {
        return a;
    }
    else
      return b;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
const int maxLineLength = 3000;
/* Declarations */
mxArray *xData,*yData,*noiseData, *kernelData;
double *xValues, *outArray,*yValues,*noiseValues, *intensityArray,x,y,sum,xPast,yPast,*normVX,*normVY,*kernelValues;
double kernelSum;
int i,j,k, sign, iteration;
int rowLen, colLen,LIClength, stepCount[4];
struct TPoint streamLine[6101];
int streamI, streamJ;
/* Copy input pointer x */
xData = prhs[1];
yData = prhs[0];
noiseData = prhs[2];
kernelData = prhs[3];

/* Get matrix x */
xValues = mxGetPr(xData); /* X component of the vector field */
yValues = mxGetPr(yData); /* Y component of the vector field */
noiseValues = mxGetPr(noiseData); /* Input noise texture */
kernelValues = mxGetPr(kernelData); /* LIC filter kernel */

rowLen = mxGetN(xData);
colLen = mxGetM(xData);
LIClength = (int)(mxGetN(kernelData) / 2);

/* Allocate memory and assign output pointer */
plhs[0] = mxCreateDoubleMatrix(colLen, rowLen, mxREAL); /* mxReal is our data-type */
plhs[1] = mxCreateDoubleMatrix(colLen, rowLen, mxREAL); 
plhs[2] = mxCreateDoubleMatrix(colLen, rowLen, mxREAL); 
plhs[3] = mxCreateDoubleMatrix(colLen, rowLen, mxREAL); 

/* Get a pointer to the data space in our newly allocated memory */
outArray = mxGetPr(plhs[0]);
intensityArray = mxGetPr(plhs[1]);
normVX = mxGetPr(plhs[3]);
normVY = mxGetPr(plhs[2]);



/* Normalizing the vector field */
for(i=0;i<rowLen;i++)
{
    for(j=0;j<colLen;j++)
    {
        intensityArray[(i*colLen)+j] = sqrt( xValues[(i*colLen)+j] * xValues[(i*colLen)+j] + yValues[(i*colLen)+j] * yValues[(i*colLen)+j] );
        outArray[(i*colLen)+j] = -1;
		if (intensityArray[(i*colLen)+j] != 0)  
		{
            normVX[(i*colLen)+j] = xValues[(i*colLen)+j] / intensityArray[(i*colLen)+j];
            normVY[(i*colLen)+j] = yValues[(i*colLen)+j] / intensityArray[(i*colLen)+j];
		}
        else
        {
            normVX[(i*colLen)+j] = xValues[(i*colLen)+j] ;
            normVY[(i*colLen)+j] = yValues[(i*colLen)+j] ;
        }
		}
}

/* Calculating stream-lines and LIC output image */

for(i=0;i<rowLen;i++)
{
    for(j=0;j<colLen;j++)
    if (outArray[(i*colLen)+j] == -1)
    {
    /* Calculating stream-lines */      
	for (sign=-1;sign<2;sign = sign + 2)
	if (sign != 0)
	{
        iteration = sign + 1;
        stepCount[iteration] = 0;
		x = i; y = j;	
        streamLine[maxLineLength].x = (int)(x);
        streamLine[maxLineLength].y = (int)(y);
		for (k=1;k<maxLineLength;k++)
		{
			xPast = x;
            yPast = y;

			x = x + sign * normVX[((int)(xPast))*colLen+(int)(yPast)] ;
            if (x < 0)  break;
            if (x > rowLen - 1) break; 

            
            y = y + sign * normVY[((int)(x))*colLen+(int)(y)];
            if (y < 0)  break;
            if (y > colLen - 1) break; 
                           
			if ((((int)(x) != (int)(xPast)) || ((int)(y) != (int)(yPast)) ))
			{
               stepCount[iteration]++;
               if (stepCount[iteration] > maxLineLength) break;
               streamLine[maxLineLength + sign * stepCount[iteration]].x = (int)(x);
               streamLine[maxLineLength + sign * stepCount[iteration]].y = (int)(y);
        	}
            if ( (k > 10) && ((int)(x) == i) && ((int)(y) == j) ) break;
          }
	}
    
        /* Calculating LIC output for pixels on the calculated stream-line */
   
        for(streamI=maxLineLength - stepCount[0];streamI<maxLineLength + stepCount[2];streamI++)
        if (outArray[(streamLine[streamI].x*colLen)+streamLine[streamI].y] == -1) 
        {
            sum = 0;
            kernelSum = 0;
            for (streamJ = maximumOf(streamI - LIClength, maxLineLength - stepCount[0]); streamJ < minimumOf(streamI + LIClength, maxLineLength + stepCount[2] ); streamJ++ )
            {
               sum += kernelValues[streamJ - streamI + LIClength] * noiseValues[(streamLine[streamJ].x*colLen)+streamLine[streamJ].y];
               kernelSum += kernelValues[streamJ - streamI + LIClength];
              
            }
            outArray[(streamLine[streamI].x*colLen)+streamLine[streamI].y] = sum / kernelSum;
        
        }
       
	}
    
    }
	
}
