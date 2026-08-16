import { IsOptional, IsString } from "class-validator";

export class ApproveLeaveDto {
    @IsString()
    approvedBy: string;
}

export class RejectLeaveDto {
    @IsString()
    rejectedBy: string;

    @IsOptional()
    @IsString()
    rejectNote?: string;
}