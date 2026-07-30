import { UserRole } from "@hris/shared-types";
import { Injectable , CanActivate, ExecutionContext, ForbiddenException} from "@nestjs/common";
import { Reflector } from "@nestjs/core";


@Injectable()
export class RolesGuard implements CanActivate {
    constructor(private reflector: Reflector ) {}

    canActivate(context: ExecutionContext): boolean {
        const requiredRoles = this.reflector.getAllAndOverride<UserRole>(
            'roles', [
                context.getHandler(),
                context.getClass(),
            ]
        );

        if (!requiredRoles) return true;

        const { user } = context.switchToHttp().getRequest();

        if (!requiredRoles.includes(user.role)) {
            throw new ForbiddenException('Akses ditolak, role tidak sesuai');
        }

        return true;

    }

}