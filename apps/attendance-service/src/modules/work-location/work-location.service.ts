import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from 'src/prisma.service';
import { CreateWorkLocationDto } from './dto/create-work-location.dto';

@Injectable()
export class WorkLocationService {
    constructor(private prisma: PrismaService){}

    async create(tenantId: string, dto: CreateWorkLocationDto) {
        const location = await this.prisma.workLocation.create({
            data: { tenantId, ...dto },
        });
        return { message: 'Lokasi kerja berhasi dibuat', data: location}
    }

    async findAll(tenantId: string){
        const locations = await this.prisma.workLocation.findMany({
            where: {tenantId, isActive: true},
            orderBy: { name: 'asc' },
        });
        return { message: 'OK', data: locations};
    }
    async findOne(tenantId: string, id: string) {
    const location = await this.prisma.workLocation.findFirst({
      where: { id, tenantId },
    });
    if (!location) throw new NotFoundException('Lokasi kerja tidak ditemukan');
    return { message: 'OK', data: location };
  }

  async findAllRaw(tenantId: string) {
    return this.prisma.workLocation.findMany({
      where: { tenantId, isActive: true },
    });
  }
}
