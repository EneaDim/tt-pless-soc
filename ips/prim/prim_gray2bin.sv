module gray_to_binary #(
    parameter int N = -1
)(
    input  logic [N-1:0] A,
    output logic [N-1:0] Z
);
    for (genvar i = 0; i < N; i++)
        assign Z[i] = ^A[N-1:i];
endmodule
