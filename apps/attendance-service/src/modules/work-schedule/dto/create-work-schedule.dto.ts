import { IsString, IsNumber, IsOptional, Min} from 'class-validator'

export class CreateWorkScheduleDto {
    @IsString()
    name: string;

    @IsString()
    checkInStart: string;

    @IsString()
    checkInEnd: string;

    @IsString()
    checkOutStart: string;

    @IsString()
    checkOutEnd: string;

    @IsOptional()
    @IsNumber()
    @Min(0)
    lateTolerance?: number;
}