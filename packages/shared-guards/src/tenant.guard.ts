import { CanActivate, ExecutionContext, ForbiddenException, Injectable } from "@nestjs/common";

@Injectable()
export class TenantGuard implements CanActivate{
    canActivate(context: ExecutionContext): boolean {
        const request = context.switchToHttp().getRequest();
        const user = request.user;
        const tenantIdFromHeader = request.headers['x-tenant-id'];

        if (!user) return false;

        if(tenantIdFromHeader && tenantIdFromHeader !== user.tenantId){
            throw new ForbiddenException('akses ditolak, tenant tidak cocok');
        }

        request.tenantId = user.tenantId;
        return true;
    }
}