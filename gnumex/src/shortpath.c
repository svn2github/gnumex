/* shortpath */
/* return short form path name for long form */
/* second  arg is a long form path name */

#include <windows.h>
#include <string.h>
#include <dirent.h>
#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  char *inpath, outpath[_MAX_PATH];
  DWORD len;

  if (nlhs < 1)
    mexErrMsgTxt("Expecting to return a file path");
  if (nrhs < 1)
    mexErrMsgTxt("Need to specify path");
  len = mxGetN(prhs[0]);
  inpath = (char *)mxCalloc(len+1, sizeof(char));
  mxGetString(prhs[0],inpath,len+1);

  len = GetShortPathName(
			 inpath,
			 outpath,
			 _MAX_PATH
			 );

  if (len==0) /* error, maybe doesn't support 8.3 names */
    strcpy(outpath, inpath);
		
  plhs[0]=mxCreateString(outpath);
	
  /* return no of chars as error index (0=did not work)*/
  if (nlhs > 1) {
    plhs[1]=mxCreateDoubleMatrix(1, 1, mxREAL);
    *mxGetPr(plhs[1])=(double)len;
  }
  mxFree(inpath);

} 

