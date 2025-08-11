import { NestFactory } from '@nestjs/core';
import { NinjaModule } from './ninja/ninja.module.js';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(NinjaModule);

  const config = new DocumentBuilder()
    .setTitle('Ninja API')
    .setDescription('Path of Exile Accountant - Ninja API')
    .setVersion('1.0')
    .addTag('ninja')
    .build();
  const documentFactory = () => SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, documentFactory);

  app.useGlobalPipes(new ValidationPipe());

  // const configService = app.get(ConfigService);

  // app.connectMicroservice<MicroserviceOptions>({
  //   transport: Transport.KAFKA,
  //   options: {
  //     client: {
  //       brokers: configService.getOrThrow<string>('KAFKA_BROKERS').split(','),
  //     }
  //   }
  // });

  await app.listen(process.env.PORT ?? 3000);
}

await bootstrap();
