import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { DepartmentModule } from './modules/department/department.module';
import { EmployeeModule } from './modules/employee/employee.module';
import { EmployeeService } from './controller/employee/employee.service';

@Module({
  imports: [DepartmentModule, EmployeeModule],
  controllers: [AppController],
  providers: [AppService, EmployeeService],
})
export class AppModule {}
