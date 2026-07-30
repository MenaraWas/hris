import { UserRole } from "./user.types";

export interface JwtPayload {
    sub:string;
    tenantId:string;
    email : string;
    role : UserRole;
    iat? : number;
    exp? : number;
}