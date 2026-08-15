import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { WorkLocationController } from './work-location.controller';
import { WorkLocationService } from './work-location.service';

@Module({
  imports: [
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => ({
        secret: configService.get('JWT_SECRET'),
      }),
      inject: [ConfigService],
    }),
  ],
  controllers: [WorkLocationController],
  providers: [WorkLocationService],
  exports: [WorkLocationService],
})
export class WorkLocationModule {}