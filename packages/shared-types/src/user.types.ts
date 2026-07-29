export type UserRole = 'super_admin' | 'admin' | 'employe';

export interface User {
    id : string;
    tenantId : string;
    name: string;
    email: string;
    role:UserRole;
    isActive:boolean;

}