export function toStartOfDay(date:Date): Date {
    const d = new Date(date);
    d.setHours(0,0,0,0);
    return d;
}

export function toEndOfDay(date:Date): Date {
    const d = new Date(date);
    d.setHours(23,59,59,999);
    return d;
}

export function isSameDay(date1: Date, date2:Date): boolean
{
    return  (
        date1.getFullYear() === date2.getFullYear() &&
        date1.getMonth() === date2.getMonth() &&
        date1.getDate() === date2.getDate()
    );
}

export function getMonthRange(year: number, month: number): { start: Date; end: Date } {
  const start = new Date(year, month - 1, 1, 0, 0, 0, 0);
  const end = new Date(year, month, 0, 23, 59, 59, 999);
  return { start, end };
}