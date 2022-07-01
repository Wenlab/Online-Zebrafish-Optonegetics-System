#define _CRT_SECURE_NO_WARNINGS

#include"initANDcheck.h"

#include "gdal_alg.h";
#include "gdal_priv.h"
#include <gdal.h>

#include <chrono>//标准模板库中与时间有关的头文件
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>

#include<fstream>
#include <iomanip> // 设置输出格式

using namespace std;
//using namespace chrono;
//打印设备信息
void printDeviceProp(const cudaDeviceProp &prop)
{
	printf("GPU Parament：\n");
	printf(" Device Name : %s.\n", prop.name);
	printf(" totalGlobalMem : %I64d.\n", prop.totalGlobalMem);
	printf(" sharedMemPerBlock : %d.\n", prop.sharedMemPerBlock);
	printf(" regsPerBlock : %d.\n", prop.regsPerBlock);
	printf(" warpSize : %d.\n", prop.warpSize);
	printf(" memPitch : %d.\n", prop.memPitch);
	printf(" maxThreadsPerBlock : %d.\n", prop.maxThreadsPerBlock);
	printf(" maxThreadsDim[0 - 2] : %d %d %d.\n", prop.maxThreadsDim[0], prop.maxThreadsDim[1], prop.maxThreadsDim[2]);
	printf(" maxGridSize[0 - 2] : %d %d %d.\n", prop.maxGridSize[0], prop.maxGridSize[1], prop.maxGridSize[2]);
	printf(" totalConstMem : %d.\n", prop.totalConstMem);
	printf(" major.minor : %d.%d.\n", prop.major, prop.minor);
	printf(" clockRate : %d.\n", prop.clockRate);
	printf(" textureAlignment : %d.\n", prop.textureAlignment);
	printf(" deviceOverlap : %d.\n", prop.deviceOverlap);
	printf(" multiProcessorCount : %d.\n", prop.multiProcessorCount);
	std::printf(" CUDA core: %d\r\n", 2 * prop.multiProcessorCount* prop.maxThreadsPerMultiProcessor / prop.warpSize);
	printf("\n\n");
}
//CUDA 初始化
bool InitCUDA()
{
	int count;
	//取得支持Cuda的装置的数目
	cudaGetDeviceCount(&count);
	if (count == 0) {
		fprintf(stderr, "There is no device.\n");
		return false;
	}
	int i;
	for (i = 0; i < count; i++) {
		cudaDeviceProp prop;
		cudaGetDeviceProperties(&prop, i);
		//打印设备信息
		printDeviceProp(prop);
		//获得显卡的时钟频率
		int clockRate = prop.clockRate;
		if (cudaGetDeviceProperties(&prop, i) == cudaSuccess) {
			if (prop.major >= 1) {
				break;
			}
		}
	}
	if (i == count) {
		fprintf(stderr, "There is no device supporting CUDA 1.x.\n");
		return false;
	}
	cudaSetDevice(i);
	return true;
}
void check(cudaError_t res, string warningstring)
{
	if (res != cudaSuccess)
	{
		printf((warningstring + " !\n").c_str());
		system("pause");
		exit(0);
	}
}


void check1(cudaError_t res, string warningstring, const char *file, int linenum)
{
	//用法check1(cudaMalloc((void**)&aa, 10 * sizeof(float)), "aa cudaMalloc Error", __FILE__, __LINE__);
	if (res != cudaSuccess)
	{
		printf((warningstring + " !\n").c_str());
		printf("   Error text: %s   Error code: %d\n", cudaGetErrorString(res), res);
		printf("   Line:    %d    File:    %s\n", linenum, file);
		system("pause");
		exit(0);
	}
}


//查看GPU运行是否正确
void checkGPUStatus(cudaError_t cudaGetLastError, string warningstring)
{
	if (cudaGetLastError != cudaSuccess)
	{
		printf("\n\n");
		printf((warningstring + " !\n").c_str());
		fprintf(stderr, "%s\n", cudaGetErrorString(cudaGetLastError));
		system("pause");
		exit(0);
	}
}

