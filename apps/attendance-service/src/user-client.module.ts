import { Module } from "@nestjs/common";
import { ConfigModule, ConfigService } from "@nestjs/config";
import { ClientsModule, Transport } from "@nestjs/microservices";

@Module({
    imports : [
        ClientsModule.registerAsync([
            {
                name : 'USER_SERVICE',
                imports : [ConfigModule],
                useFactory : (configService: ConfigService) => ({
                    transport : Transport.TCP,
                    options : {
                        host : configService.get<string>('USER_SERVICE_TCP_HOST'),
                        port : parseInt(configService.get<string>('USER_SERVICE_TCP_PORT', '3000'), 10),
                    },
                }),
                inject: [ConfigService],
            },
        ]),
    ],
    exports : [ClientsModule],
})

export class UserClientModule {}