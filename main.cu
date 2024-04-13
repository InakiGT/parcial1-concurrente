#include <stdio.h>
#include <stdlib.h>
#include <time.h>

__global__ void calcDeterminante(float * matriz, float * determinante, int N) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < N) {
        determinante[0] += matriz[idx] * (
            matriz[((0 + 1) % N) * N + ((idx + 1) % N)] * matriz[((0 + 2) % N) * N + ((idx + 2) % N)] -
            matriz[((0 + 1) % N) * N + ((idx + 2) % N)] * matriz[((0 + 2) % N) * N + ((idx + 1) % N)]
        );
    }
}

__global__ void matrizAdjunta(float * matriz, float * adjunta, int N) {
    int fila    = blockIdx.y * blockDim.y + threadIdx.y;
    int columna = blockIdx.x * blockDim.x + threadIdx.x;

    if (fila < N && columna < N) {
        int indice = columna * N + fila;
        adjunta[indice] = (
            matriz[((fila + 1) % N) * N + ((columna + 1) % N)] * matriz[((fila + 2) % N) * N + ((columna + 2) % N)] -
            matriz[((fila + 1) % N) * N + ((columna + 2) % N)] * matriz[((fila + 2) % N) * N + ((columna + 1) % N)]
        );

        if ((fila + columna) % 2 == 1) {
            adjunta[indice] = -adjunta[indice];
        }
    }
}

__global__ void calcInversa(float * adjunta, float * inversa, float * determinante, int N) {
    int fila    = blockIdx.y * blockDim.y + threadIdx.y;
    int columna = blockIdx.x * blockDim.x + threadIdx.x;

    if (fila < N && columna < N) {
        int indice = fila * N + columna;

        inversa[indice] = adjunta[indice] / determinante[0];
    }
}

int main(int argc, char * argv[]) {

    int N = atoi(argv[1]);
    srand(time(NULL));

    float * matriz          = (float *) malloc(N * N * sizeof(float));
    float * inversa         = (float *) malloc(N * N * sizeof(float));
    float * determinante_h  = (float *) malloc(N * sizeof(float));

    for (int i = 0; i < N * N; i++)
        matriz[i] = rand() % 100;

    printf("Matriz original: \n");
    for (int i = 0; i < N * N; i++)
        printf("%f ", matriz[i]);

    float *matriz_d, *determinante_d, *adjunta_d, *inversa_d;

    cudaMalloc(&matriz_d, N * N * sizeof(float));
    cudaMalloc(&adjunta_d, N * N * sizeof(float));
    cudaMalloc(&inversa_d, N * N * sizeof(float));
    cudaMalloc(&determinante_d, N * sizeof(float));

    cudaMemcpy(matriz_d, matriz, N * N * sizeof(float), cudaMemcpyHostToDevice);

    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, 0);

    int tambloque   = prop.maxThreadsPerBlock;
    int numbloques  = (N + tambloque - 1) / tambloque;

    calcDeterminante<<<numbloques, tambloque>>>(matriz_d, determinante_d, N);

    cudaMemcpy(determinante_h, determinante_d, N * sizeof(float), cudaMemcpyDeviceToHost);

    printf("PEPE MADERO: %f", determinante_h[0]);
    if (determinante_h[0] == 0) {
        printf("\nLa matiz no es invertible");
    } else {
        numbloques = (N * N + tambloque - 1) / tambloque;

        dim3 tamBloque(numbloques, numbloques); 
        dim3 tamMalla((N * N + numbloques - 1) / numbloques, (N * N + numbloques - 1) / numbloques);

        matrizAdjunta<<<tamMalla, tamBloque>>>(matriz_d, adjunta_d, N);
        calcInversa<<<tamMalla, tamBloque>>>(adjunta_d, inversa_d, determinante_d, N);

        cudaMemcpy(inversa, inversa_d, N * N * sizeof(float), cudaMemcpyDeviceToHost);

        printf("Matriz inversa: \n");
        for (int i = 0; i < N * N; i++)
            printf("%f ", inversa[i]);
    }

    cudaDeviceSynchronize();

    free(matriz);
    free(inversa);
    free(determinante_h);
    cudaFree(matriz_d);
    cudaFree(adjunta_d);
    cudaFree(inversa_d);
    cudaFree(determinante_d);

    return 0;
}