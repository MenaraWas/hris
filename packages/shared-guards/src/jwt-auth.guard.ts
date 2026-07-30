import { Injectable, CanActivate, ExecutionContext, UnauthorizedException } from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import { JwtPayload } from "@hris/shared-types";

@Injectable()
export class JwtAuthGuard implements CanActivate {
    constructor(private jwtService: JwtService){}

    async canActivate(context: ExecutionContext): Promise<boolean> {
        const request = context.switchToHttp().getRequest();
        const token = this.extractToken(request);

        if (!token) {
        throw new UnauthorizedException('Token tidak ditemukan');
        }

        try {
            const payload: JwtPayload = await this.jwtService.verifyAsync(token);
            request.user = payload;
            return true;
        } catch {
            throw new UnauthorizedException('Token tidak valid atau sudah expired');
        }
    }

    private extractToken(request: any):string | null {
        const authHeader = request.headers['authorization'];
        if (!authHeader) return null;
        const [type, token] = authHeader.split(' ');
        return type === 'Bearer' ? token : null;
    }
}