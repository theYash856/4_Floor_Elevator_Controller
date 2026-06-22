`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.06.2026 11:49:45
// Design Name: 
// Module Name: Elevator_controller_4_floors
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


module Elevator_controller_4_floors( 
    input clk,
    input rst,
    input emergency, // Emergency stop
    input [1:0]target_floor, // For 4 floors (0-3)
    output reg motor_up, motor_down, door_open
    );
    
    // FSM state encodings
    localparam IDLE = 2'b00; 
    localparam MOVING_UP = 2'b01;
    localparam MOVING_DOWN = 2'b10;
    localparam OPEN_DOOR = 2'b11;
    
    // State variables
    reg [1:0] state, next_state;
    reg [1:0] current_floor; // Current elevator floor
    reg [1:0] requested_floor; // It internally stores the request and doesn't change until the destination is achieved.
    reg [1:0] counter; // Delay counter for movement and door timing
    
    // Sequential state update block 
    always @(posedge clk or posedge rst) begin
        
        // Reset condition
        if (rst) begin
            state <= IDLE;
            current_floor <= 0;
            requested_floor <=0;
            counter <= 0;
            end
        
        else if (!emergency) begin
            state <= next_state;
            
            // Clear request after serving it
            if (state == OPEN_DOOR && counter == 3)
                requested_floor <= current_floor;
                
            // Accept new request only when idle
            else if (state == IDLE && target_floor != current_floor)
                requested_floor <= target_floor;
                
            // Moving up condition
            if (state == MOVING_UP && requested_floor != current_floor) begin
                if (counter == 2) begin // Change floor every 3 clock cycles
                    current_floor <= current_floor + 1;
                    counter <= 0; // Reset counter
                end
                else begin
                    counter <= counter + 1;
                end
            end
            
            // Moving down condition
            else if (state == MOVING_DOWN && requested_floor != current_floor) begin
                if (counter == 2) begin
                    current_floor <= current_floor - 1;
                    counter <= 0;
                end
                
                else begin
                    counter <= counter + 1;
                end
            end
            
            // To keep the door open for 4 clock cycles
            else if (state == OPEN_DOOR) begin
                if (counter == 3)
                    counter <= 0;
                else
                    counter <= counter + 1;
                end
            
       else begin
            counter <= 0;
            end
       end
   end
   
// Combinational next-state logic block
    always @(*) begin
        next_state = state; // Default
    
        case(state)
            IDLE: begin
                if (requested_floor > current_floor)
                    next_state = MOVING_UP;
                else if (requested_floor < current_floor)
                    next_state = MOVING_DOWN;
                end
              
            MOVING_UP: if (requested_floor  == current_floor)
                            next_state = OPEN_DOOR;
        
            MOVING_DOWN: if (requested_floor  == current_floor)
                            next_state = OPEN_DOOR;
        
            OPEN_DOOR: begin
                       if (counter == 3)
                            next_state = IDLE;
                       else
                            next_state = OPEN_DOOR;
                       end
            default:
                    next_state = IDLE;
        endcase
    end
    
    // Output logic block (Moore design)
    always @(*) begin
        if (emergency)
            {motor_up, motor_down, door_open} = 3'b000;
        else
            case(state)
                IDLE: {motor_up, motor_down, door_open} = 3'b000;
                MOVING_UP: {motor_up, motor_down, door_open} = 3'b100;
                MOVING_DOWN: {motor_up, motor_down, door_open} = 3'b010;
                OPEN_DOOR: {motor_up, motor_down, door_open} = 3'b001;
                default:
                        {motor_up, motor_down, door_open} = 3'b000;
            endcase
        end
endmodule
