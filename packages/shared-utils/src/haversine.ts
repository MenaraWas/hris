//used for attendance-service, count between gps-based location and office location

export function haversineDistance(
    lat1 : number,
    lon1 : number,
    lat2 : number,
    lon2 : number
): number {
    const R = 6371000; //earth radius in meters
    const toRad = (deg:number) => (deg*Math.PI)/180;

    const dLat = toRad(lat2 - lat1);
    const dLon = toRad(lon2 - lon1);

    const a = 
        Math.sin(dLat / 2 ) * Math.sin(dLat / 2) + 
        Math.cos(toRad(lat1)) *
            Math.cos(toRad(lat2)) *
            Math.sin(dLon/2)*
            Math.sin(dLon/2);

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    
    return R*c;
}

export function isWithinRadius(employeeLat : number, employeeLon : number, officeLat : number, OfficeLon : number, radiusInMeters: number) : boolean
{
    const distance = haversineDistance(employeeLat, employeeLon, officeLat, OfficeLon);
    return distance <= radiusInMeters;
}