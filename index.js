console.log("TEST");

const matrix = [[1, 2], [3, 4]];
const vector = [1, 2, 3, 4];

const N = matrix.length;

for (let i = 0; i < N; i++) {
    console.log("---------------------");
    console.log(matrix[(0 + 1) % N][(i + 1) % N], "x", matrix[(0 + 2) % N][(i + 2) % N]);
    console.log("-");
    console.log(matrix[(0 + 1) % N][(i + 2) % N], "x", matrix[(0 + 2) % N][(i + 1) % N]);
}

console.log("VECTOR")
for (let i = 0; i < N; i++) {
    console.log("---------------------");
    console.log(vector[((0 + 1) % N) * N + ((i + 1) % N)], "x", vector[((0 + 2) % N) * N + ((i + 2) % N)]);
    console.log("-");
    console.log(vector[((0 + 1) % N) * N + ((i + 2) % N)], "x", vector[((0 + 2) % N) * N + ((i + 1) % N)]);
}