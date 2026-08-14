import { Module } from '@nestjs/common';
import { WorkLocationService } from './work-location.service';
import { WorkLocationController } from './work-location.controller';

@Module({
  providers: [WorkLocationService],
  controllers: [WorkLocationController]
})
export class WorkLocationModule {}
