import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { MicroserviceOptions, Transport } from '@nestjs/microservices';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }));

  app.setGlobalPrefix('api');
  app.enableCors();

  //add tcp
  app.connectMicroservice<MicroserviceOptions>({
    transport: Transport.TCP,
    options: {
      host: '127.0.0.1',
      port: 4002,
    }
  })

  await app.startAllMicroservices();
  await app.listen(process.env.PORT || 3002);
  console.log('User service HTTP berjalan di port 3002');
  console.log('User service TCP berjalan di port 4002');
}

bootstrap();