/*
 * includes.h
 *
 *  Created on: 13-Apr-2019
 *      Author: Dell_PC
 */

#ifndef SHA_1_H_
#define SHA_1_H_

#define ROTATE_1		1
#define ROTATE_5		5
#define ROTATE_30		30

typedef struct HashModule
{
	unsigned int Hash[5];
	unsigned int Wi;
	unsigned int Ki;
	unsigned int (*FnRtn)(unsigned int Hash1, unsigned int Hash2, unsigned int Hash3);
}HashEntry;

HashEntry HashData;
HashEntry *HashTable_ptr;

void DataReader(unsigned char* string, int* length);

void DataPadding(unsigned char* string, int* length);

void MessageCalculator(unsigned int *Data, int Index);

unsigned int ROTL(unsigned int RotateBy, unsigned int NumberToRotate);

unsigned int Function_Iteration1(unsigned int Hash1, unsigned int Hash2, unsigned int Hash3);

unsigned int Function_Iteration2(unsigned int Hash1, unsigned int Hash2, unsigned int Hash3);

unsigned int Function_Iteration3(unsigned int Hash1, unsigned int Hash2, unsigned int Hash3);

unsigned int Function_Iteration4(unsigned int Hash1, unsigned int Hash2, unsigned int Hash3);

void SHA_Kernel(HashEntry *HashTable_ptr_local);

void sha_1_sw (void);

#endif /* SHA_1_H_ */
