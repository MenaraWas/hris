import { IsNumber, IsOptional, IsString, Min } from "class-validator";

export class CreateLeaveBalanceDto {
    @IsString()
    employeeId: string;

    @IsString()
    leaveType: string;

    @IsOptional()
    @IsNumber()
    @Min(0)
    totalDays?: number;

    @IsOptional()
    @IsNumber()
    year?: number;
}