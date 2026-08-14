-- CreateTable
CREATE TABLE "work_locations" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION NOT NULL,
    "longitude" DOUBLE PRECISION NOT NULL,
    "radiusInMeters" DOUBLE PRECISION NOT NULL DEFAULT 100,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "work_locations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "work_schedules" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "checkInStart" TEXT NOT NULL,
    "checkInEnd" TEXT NOT NULL,
    "checkOutStart" TEXT NOT NULL,
    "checkOutEnd" TEXT NOT NULL,
    "lateTolerance" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "work_schedules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attendances" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "employeeId" TEXT NOT NULL,
    "workLocationId" TEXT,
    "date" TIMESTAMP(3) NOT NULL,
    "checkInTime" TIMESTAMP(3),
    "checkOutTime" TIMESTAMP(3),
    "checkInLat" DOUBLE PRECISION,
    "checkInLon" DOUBLE PRECISION,
    "checkOutLat" DOUBLE PRECISION,
    "checkOutLon" DOUBLE PRECISION,
    "status" TEXT NOT NULL DEFAULT 'absent',
    "note" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "attendances_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "attendances_employeeId_date_tenantId_key" ON "attendances"("employeeId", "date", "tenantId");

-- AddForeignKey
ALTER TABLE "attendances" ADD CONSTRAINT "attendances_workLocationId_fkey" FOREIGN KEY ("workLocationId") REFERENCES "work_locations"("id") ON DELETE SET NULL ON UPDATE CASCADE;
