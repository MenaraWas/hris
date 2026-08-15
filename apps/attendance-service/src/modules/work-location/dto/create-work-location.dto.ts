import { IsString, IsNumber, IsOptional, Min, Max } from 'class-validator';

export class CreateWorkLocationDto {
  @IsString()
  name: string;

  @IsNumber()
  @Min(-90)
  @Max(90)
  latitude: number;

  @IsNumber()
  @Min(-180)
  @Max(180)
  longitude: number;

  @IsOptional()
  @IsNumber()
  radiusInMeters?: number;
}