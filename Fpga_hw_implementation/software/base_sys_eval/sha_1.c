#include <stdio.h>
#include <string.h>
#include "sha_1.h"

unsigned int H[5] = {0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0};
unsigned int K[4] = {0x5A827999, 0x6ED9EBA1, 0x8F1BBCDC, 0xCA62C1D6};
unsigned int ASCII[80] = {0};
unsigned int (*FnPtr[4])(unsigned int Hash1, unsigned int Hash2, unsigned int Hash3);

void sha_1_sw (void)
{
	//setbuf(stdout, NULL);
	unsigned char input[64];
	int length = 0, block = -1;

	memset(input, 0, sizeof(input));

	input[0] = 'a';
	input[1] = 'b';
	input[2] = 'c';

	FnPtr[0] = Function_Iteration1;
	FnPtr[1] = Function_Iteration2;
	FnPtr[2] = Function_Iteration3;
	FnPtr[3] = Function_Iteration4;

	HashTable_ptr = &HashData;

	DataReader(input,&length);
	DataPadding(input,&length);


	for(unsigned int i = 0; i < 5; i++)
	{
		HashTable_ptr->Hash[i] = H[i];
	}

	for(unsigned int i = 0; i < 80; i++)
	{
		if((i % 20) == 0)
		{
			++block;
		}
		HashTable_ptr->Ki = K[block];
		HashTable_ptr->FnRtn = FnPtr[block];
		MessageCalculator(ASCII,i);
		HashTable_ptr->Wi = ASCII[i];
		SHA_Kernel(HashTable_ptr);
	}

	for(unsigned int j = 0; j < 5; j++)
	{
		H[j] += HashTable_ptr->Hash[j];
	}

	/*Only for printing purposes to see the final hash of 160 bits
	 * should always be outside the outermost loop
	 */
	printf("Hash Value is:\n");
	printf("%08x ",H[0]);
	printf("%08x ",H[1]);
	printf("%08x ",H[2]);
	printf("%08x ",H[3]);
	printf("%08x ",H[4]);
	printf("\n\n");
}


void DataReader(unsigned char* string,int* length)
{

	for(unsigned int i = 0; string[i] != '\0'; i++)
	{
		(*length)++;
	}
}

void DataPadding(unsigned char* string, int* length)
{
	int pos = 0, Num = 0;

	// add the length of the data
	string[63] = (*length) * 8;
#if 1
	if ((*length) < 56)
		string[*length] = 0x80;

	for(unsigned int i = 0; i < 16; i++)
	{
		Num = ((int)(string[0 + pos]) << 24) | ((int)(string[1 + pos]) << 16) | ((int)(string[2 + pos]) << 8) | (int)(string[3 + pos]);
		ASCII[i] = Num;
		pos += 4;
		Num = 0;
	}
#else
	if(((*length)%4) == 0)
	{
		ASCII[(*length)/4] |= 0x01 << 31;
	}
	else
	{
		ASCII[(*length)/4] |= 0x01 << (((4 - (*length)%4) * 8) - 1);
	}
#endif
}

unsigned int Function_Iteration1(unsigned int Hash1, unsigned int Hash2, unsigned int Hash3)
{
	return((Hash1 & Hash2) ^ (~(Hash1) & Hash3));
}

unsigned int Function_Iteration2(unsigned int Hash1, unsigned int Hash2, unsigned int Hash3)
{
	return(Hash1 ^ Hash2 ^ Hash3);
}

unsigned int Function_Iteration3(unsigned int Hash1, unsigned int Hash2, unsigned int Hash3)
{
	return((Hash1 & Hash2) ^ (Hash2 & Hash3) ^ (Hash3 & Hash1));
}

unsigned int Function_Iteration4(unsigned int Hash1, unsigned int Hash2, unsigned int Hash3)
{
	return(Hash1 ^ Hash2 ^ Hash3);
}

void MessageCalculator(unsigned int *Data, int Index)
{
	unsigned int temp = 0;
	if(Index >= 16)
	{
		temp = (Data[((Index - 3))] ^ Data[((Index - 8))] ^ Data[((Index - 14))] ^ Data[((Index - 16))]);
		Data[Index] = ROTL(ROTATE_1,temp);
	}
}

unsigned int ROTL(unsigned int RotateBy, unsigned int NumberToRotate)
{
	return((NumberToRotate << RotateBy) | (NumberToRotate >> (sizeof(unsigned int) * 8 - RotateBy)));
}

void SHA_Kernel(HashEntry *HashTable_ptr_local)
{
	HashEntry Temp = *HashTable_ptr_local;
	unsigned int temp_hash;

	HashTable_ptr_local->Hash[1] = HashTable_ptr_local->Hash[0];
	HashTable_ptr_local->Hash[2] = ROTL(ROTATE_30,Temp.Hash[1]);
	HashTable_ptr_local->Hash[3] = Temp.Hash[2];
	HashTable_ptr_local->Hash[4] = Temp.Hash[3];

	temp_hash = Temp.Hash[4] + HashTable_ptr_local->Wi + HashTable_ptr_local->Ki + HashTable_ptr_local->FnRtn(Temp.Hash[1],Temp.Hash[2],Temp.Hash[3]);
	HashTable_ptr_local->Hash[0] = temp_hash + ROTL(ROTATE_5,Temp.Hash[0]);
}
