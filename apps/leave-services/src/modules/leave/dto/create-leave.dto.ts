import { IsDateString, IsString, MinLength } from "class-validator";

export class CreateLeaveDto {
    @IsString()
    employeeId: string;

    @IsString()
    leaveType: string;

    @IsDateString()
    startDate: string;

    @IsDateString()
    endDate: string;

    @IsString()
    @MinLength(10)
    reason: string;
}