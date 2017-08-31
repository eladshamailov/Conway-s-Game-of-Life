extern char state[100000];
extern int WorldWidth;
extern int WorldLength;
char cell(int i, int j){
int count=0;
int myCell;
char alive;
int indexI;
int indexJ;
int realJnum;
int realInum;
int curCell;
myCell = i*(WorldWidth+1)+j;
alive = state[myCell];
indexI=i-1;
while (indexI<=i+1){
    indexJ=j-1;
    while (indexJ<=j+1){
           realInum = (indexI+WorldLength)%WorldLength;
	   realJnum = (indexJ+WorldWidth)%WorldWidth;
      if (realInum==i&&realJnum==j){
         curCell=0;

     }
	else{
       curCell = (realInum*(WorldWidth+1))+realJnum;
       if (state[curCell]>'0'){
          count++;
       	      }
	   }
	indexJ++;
     }
     indexI++;
}

if (count>3) return '0';

if (count ==3){
if(alive<'9') return alive+1;
return '9';
}

if (count!=2||alive<='0'){
return '0';
}
else{
if(alive<'9') return alive+1;
return '9';
}
}

