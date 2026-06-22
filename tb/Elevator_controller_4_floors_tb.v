`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.06.2026 12:14:08
// Design Name: 
// Module Name: Elevator_controller_4_floors_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Elevator_controller_4_floors_tb;

    reg clk_tb, rst_tb;
    reg emergency_tb;
    reg [1:0] target_floor_tb;

    wire motor_up_tb;
    wire motor_down_tb;
    wire door_open_tb;

    Elevator_controller_4_floors uut(
        .clk(clk_tb),
        .rst(rst_tb),
        .emergency(emergency_tb),
        .target_floor(target_floor_tb),
        .motor_up(motor_up_tb),
        .motor_down(motor_down_tb),
        .door_open(door_open_tb)
    );

    // Clock generation
    always #5 clk_tb = ~clk_tb;

    initial begin
        // Initial conditions
        clk_tb = 0;
        rst_tb = 1;
        emergency_tb = 0;
        target_floor_tb = 0;

        #10 rst_tb = 0;

        // Test 1 : Upward movement (0 -> 3)
        target_floor_tb = 3;
        #180;

        // Test 2 : Downward movement (3 -> 1)
        target_floor_tb = 1;
        #140;

        // Test 3 : Same floor request ignored; Elevator already at floor 1
        target_floor_tb = 1;
        #40;

        // Test 4 : Target changed during motion; Elevator should continue to finish its ongoing request.
        target_floor_tb = 3;
        #30;
        target_floor_tb = 0;
        #180;

        // Test 5 : Emergency stop; Outputs must become zero, then resume.
        target_floor_tb = 2;
        #50;
        emergency_tb = 1;
        #40;
        emergency_tb = 0;
        #80;

        // Test 6 : Reset operation; Elevator returns to floor 0.
        rst_tb = 1;
        #10;
        rst_tb = 0;

        target_floor_tb = 3;
        #180;
        $finish;
    end

    initial begin
        $monitor(
            "Time=%0t ns| State=%b | Floor=%0d | Req=%0d | Target=%0d | Count=%0d | Up=%b | Down=%b | Door=%b | Emergency=%b",
            $time,
            uut.state,
            uut.current_floor,
            uut.requested_floor,
            target_floor_tb,
            uut.counter,
            motor_up_tb,
            motor_down_tb,
            door_open_tb,
            emergency_tb
        );
    end
endmodule