/* =========================================================
   DATABASE : ASSET CONTROL SYSTEM
   DESCRIPTION : ระบบควบคุมครุภัณฑ์คอมพิวเตอร์ IT
   AUTHOR : NOTE
   LEVEL : Enterprise Structure
========================================================= */

/* =========================================================
   1️⃣ ER Diagram ของ Database ทั้งระบบ 
   2️⃣ Flow ระบบ Approve แบบ Enterprise (IT จริงใช้แบบนี้) 
   3️⃣ SQL Trigger Auto Save approve_log
*/

/* =========================================================
   SECTION 1 : USER MANAGEMENT
   เก็บข้อมูลผู้ใช้งานระบบ
========================================================= */
CREATE TABLE ext26_assetcontrol_user(
    id_user INT IDENTITY(1,1) PRIMARY KEY,       -- รหัสหลักของ User
    id_emp NVARCHAR(50) NOT NULL,                -- รหัสพนักงาน (เชื่อมกับระบบ HR ภายนอก)
    username NVARCHAR(50) NOT NULL UNIQUE,       -- ชื่อผู้ใช้งาน (ห้ามซ้ำ)
    user_password NVARCHAR(255) NOT NULL,        -- เก็บ HASH เท่านั้น
    remark NVARCHAR (255) NULL,                  -- หมายเหตุเพิ่มเติม
    create_by  NVARCHAR(50) null,                -- ผู้สร้างข้อมูล (อาจจะเป็น Admin หรือระบบอัตโนมัติ)
    create_date DATETIME NOT NULL,               -- วันที่สร้างข้อมูล
    update_by NVARCHAR(50) NULL,                 -- ผู้แก้ไขข้อมูลล่าสุด
    update_date DATETIME NULL,                   -- วันที่แก้ไขข้อมูลล่าสุด
    cancel_by NVARCHAR(50) NULL,                 -- ผู้ยกเลิกข้อมูล (Soft Delete)         
    cancel_date DATETIME NULL,                   -- วันที่ยกเลิกข้อมูล (Soft Delete)
    is_active BIT NOT NULL DEFAULT 1             -- 1 = ใช้งาน -- 0 = ยกเลิก (Soft Delete)
);



/* =========================================================
   ROLE MASTER
   กำหนดสิทธิ์การใช้งาน
========================================================= */
IF OBJECT_ID('dbo.ext26_assetcontrol_role', 'U') IS NULL
BEGIN
    CREATE TABLE ext26_assetcontrol_role(
        id_role INT IDENTITY(1,1) PRIMARY KEY,   -- รหัส Role
        role_name NVARCHAR(50) NOT NULL UNIQUE,  -- ชื่อสิทธิ์ เช่น ADMIN, USER  UNIQUE = ห้ามชื่อซ้ำ
        description NVARCHAR(255) NULL,          -- คำอธิบายสิทธิ์
        remark NVARCHAR(255) NULL,               -- หมายเหตุเพิ่มเติม
        create_by  NVARCHAR(50) null,            -- ผู้สร้างข้อมูล (อาจจะเป็น Admin หรือระบบอัตโนมัติ) 
        create_date DATETIME NOT NULL DEFAULT GETDATE(), -- วันที่สร้างข้อมูล
        update_by NVARCHAR(50) NULL,             -- ผู้แก้ไขข้อมูลล่าสุด
        update_date DATETIME NULL,               -- วันที่แก้ไขข้อมูลล่าสุด
        cancel_by NVARCHAR(50) NULL,             -- ผู้ยกเลิกข้อมูล (Soft Delete)
        cancel_date DATETIME NULL                -- วันที่ยกเลิกข้อมูล (Soft Delete)
    );
END

IF COL_LENGTH('dbo.ext26_assetcontrol_role', 'description') IS NULL
BEGIN
    ALTER TABLE dbo.ext26_assetcontrol_role
    ADD description NVARCHAR(255) NULL;
END



IF COL_LENGTH('dbo.ext26_assetcontrol_role', 'description') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.ext26_assetcontrol_role WHERE role_name = 'Admin')
        INSERT INTO dbo.ext26_assetcontrol_role (role_name, description)
        VALUES ('Admin', 'Full Access');

    IF NOT EXISTS (SELECT 1 FROM dbo.ext26_assetcontrol_role WHERE role_name = 'User')
        INSERT INTO dbo.ext26_assetcontrol_role (role_name, description)
        VALUES ('User', 'Normal Access');
END
ELSE
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.ext26_assetcontrol_role WHERE role_name = 'Admin')
        INSERT INTO dbo.ext26_assetcontrol_role (role_name, remark)
        VALUES ('Admin', 'Full Access');

    IF NOT EXISTS (SELECT 1 FROM dbo.ext26_assetcontrol_role WHERE role_name = 'User')
        INSERT INTO dbo.ext26_assetcontrol_role (role_name, remark)
        VALUES ('User', 'Normal Access');
END

-- =========================================
-- RESULT CHECK
-- =========================================
SELECT * FROM ext26_assetcontrol_role;


/* =========================================================
   DEPARTMENT
   เก็บข้อมูลแผนกในองค์กร
========================================================= */
CREATE TABLE ext26_assetcontrol_department(
    id_dept INT IDENTITY(1,1) PRIMARY KEY,           -- รหัสหลักของแผนก
    code_dept NVARCHAR(20) NOT NULL UNIQUE,          -- รหัสแผนก เช่น IT, HR  UNIQUE = ห้ามรหัสซ้ำ
    dept_name NVARCHAR (100) NOT NULL,               -- ชื่อแผนก
    factory NVARCHAR(20) NULL,                       -- โรงงาน (ถ้ามี)
    create_date DATETIME NOT NULL DEFAULT GETDATE(), -- วันที่สร้างข้อมูล
    is_active BIT NOT NULL DEFAULT 1                 -- 1 = ใช้งาน -- 0 = ยกเลิก (Soft Delete)
);



/* =========================================================
   STATUS MASTER
   ตารางเก็บสถานะของ Asset
   แยกเป็น Master เพื่อความเป็นระบบ
========================================================= */
CREATE TABLE ext26_assetcontrol_status(
    id_status INT PRIMARY KEY,                      -- รหัสสถานะ เช่น 1, 2, 3
    status_name NVARCHAR(100) NOT NULL UNIQUE       -- ชื่อสถานะ เช่น พร้อมใช้งาน, กำลังใช้งาน, ส่งซ่อมภายนอก เป็นต้น UNIQUE = ห้ามชื่อซ้ำ
);

INSERT INTO ext26_assetcontrol_status VALUES                            
(1,N'พร้อมใช้งาน'),
(2,N'กำลังใช้งาน'),
(3,N'ส่งซ่อมภายนอก'),
(4,N'อยู่ระหว่างโอนย้าย'),
(5,N'เสียหายไม่สามารถซ่อมได้'),
(6,N'อยู่ระหว่างการยืมใช้งาน'),
(7,N'เกินกำหนดการคืน');

-- ตารางสถานะกลางสำหรับงานยืมทั้ง Hardware และ Asset
CREATE TABLE ext26_assetcontrol_borrow_status(
    id_status INT PRIMARY KEY,                       -- รหัสสถานะการยืม เช่น 1, 2, 3
    status_name NVARCHAR(50) NOT NULL UNIQUE         -- ชื่อสถานะการยืม เช่น กำลังยืม, คืนแล้ว, เกินกำหนด
);

INSERT INTO ext26_assetcontrol_borrow_status VALUES
(1,N'กำลังยืม'),
(2,N'คืนแล้ว'),
(3,N'เกินกำหนด');

CREATE TABLE ext26_assetcontrol_type_computer (
    id_type_com INT IDENTITY(1,1) PRIMARY KEY,
    type_computer NVARCHAR(100) NOT NULL     -- ชื่อที่แสดงใน Dropdown

);

INSERT INTO ext26_assetcontrol_type_computer (type_computer)
VALUES 
(N'PC'),
(N'Notebook'),
(N'Tablet');


/* =========================================================
    COMPUTER SPEC
   เก็บสเปคกลาง (Model กลาง)
   1 Spec สามารถมีหลาย Asset ได้
========================================================= */
CREATE TABLE ext26_assetcontrol_computer_spec(  
    id_com_spec INT IDENTITY(1,1) PRIMARY KEY,
    id_type_com INT NOT NULL,              -- ประเภท เช่น PC Notebook Tablet
    brand NVARCHAR(50) NULL,           -- Dell Lenovo Asus HP    
    model NVARCHAR(50) NULL,           -- ชื่อรุ่น เช่น Dell Latitude 5420
    cpu NVARCHAR(50) NULL,             -- รายละเอียด CPU เช่น Intel i5-11400H
    gpu NVARCHAR(50) NULL,             -- รายละเอียด GPU เช่น NVIDIA GTX 1650
    memory NVARCHAR(50) NULL,          -- ขนาด RAM เช่น 8GB, 16GB
    disk_size NVARCHAR(50) NULL,       -- ขนาด HDD/SSD เช่น 512GB, 1TB
    os NVARCHAR(50) NULL,              -- ระบบปฏิบัติการ เช่น Windows 10 Pro 
    remark NVARCHAR (255) NULL,        -- หมายเหตุ
    create_by  NVARCHAR(50) null,      -- ผู้สร้างข้อมูล (อาจจะเป็น Admin หรือระบบอัตโนมัติ)
    create_date DATETIME NOT NULL,     -- วันที่สร้างข้อมูล
    update_by NVARCHAR(50) NULL,       -- ผู้แก้ไขข้อมูลล่าสุด
    update_date DATETIME NULL,         -- วันที่แก้ไขข้อมูลล่าสุด
    cancel_by NVARCHAR(50) NULL,       -- ผู้ยกเลิกข้อมูล (Soft Delete)    
    cancel_date DATETIME NULL,         -- วันที่ยกเลิกข้อมูล (Soft Delete)
    FOREIGN KEY (id_type_com) REFERENCES ext26_assetcontrol_type_computer(id_type_com)
);

/* =========================================================
    HARDWARE MASTER
   เก็บข้อมูลครุภัณฑ์/อุปกรณ์ที่มีอยู่ทั้งหมด
========================================================= */
CREATE TABLE ext26_assetcontrol_hardware_type (
    id_type_hardware INT IDENTITY(1,1) PRIMARY KEY,
    hardware_name NVARCHAR(100) NOT NULL     -- ชื่อที่แสดงใน Dropdown
);

INSERT INTO ext26_assetcontrol_hardware_type (hardware_name)
VALUES
(N'Monitor'),
(N'Mouse'),
(N'Keyboard'),
(N'HDD 512GB'),
(N'HDD 1TB'),
(N'SSD SATA 512GB'),
(N'SSD SATA 1TB'),
(N'RAM 8GB'),
(N'RAM 16GB'),
(N'HDMI'),
(N'VGA'),
(N'DisplayPort'),
(N'DVI'),
(N'RJ45'),
(N'HDMI to VGA'),
(N'VGA to DisplayPort'),
(N'VGA to DVI'),
(N'DVI to HDMI'),
(N'Switch Hub 8 Port'),
(N'Switch Hub 16 Port'),
(N'Switch Hub 24 Port'),
(N'Switch Hub 48 Port');


CREATE TABLE ext26_assetcontrol_hardware (
    id_hardware INT IDENTITY(1,1) PRIMARY KEY,   
    id_type_hardware INT NOT NULL,               -- ประเภทอุปกรณ์ เช่น Peripheral / Accessory / Network
    detail_hardware NVARCHAR(100) NOT NULL,      -- รายละเอียดเพิ่มเติม เช่น ยี่ห้อ รุ่น ขนาด สี เป็นต้น
    total_qty INT NOT NULL,                      -- จำนวนทั้งหมด (ห้ามติดลบ)
    public_total_qty INT NOT NULL,               -- จำนวนที่อนุญาตให้บุคคลทั่วไปใช้งาน
    public_all BIT NOT NULL DEFAULT 0,           -- 1 = ใช้ได้ทุกคน 0 = เฉพาะสิทธิ์ที่กำหนด
    remark NVARCHAR(255) NULL,                   -- หมายเหตุ                                                                  
    create_by  NVARCHAR(50) null,                -- ผู้สร้างข้อมูล (อาจจะเป็น Admin หรือระบบอัตโนมัติ)
    create_date DATETIME NOT NULL,               -- วันที่สร้างข้อมูล
    update_by NVARCHAR(50) NULL,                 -- ผู้แก้ไขข้อมูลล่าสุด
    update_date DATETIME NULL,                   -- วันที่แก้ไขข้อมูลล่าสุด
    cancel_by NVARCHAR(50) NULL,                 -- ผู้ยกเลิกข้อมูล (Soft Delete)
    cancel_date DATETIME NULL,                   -- วันที่ยกเลิกข้อมูล (Soft Delete)
    FOREIGN KEY (id_type_hardware) REFERENCES ext26_assetcontrol_hardware_type(id_type_hardware)
   
);

CREATE TABLE ext26_assetcontrol_hardware_log (
    id_hardware_log INT IDENTITY(1,1) PRIMARY KEY,
    id_hardware INT NOT NULL,   
    id_type_hardware INT NOT NULL,               -- ประเภทอุปกรณ์ เช่น Peripheral / Accessory / Network
    detail_hardware NVARCHAR(100) NOT NULL,      -- รายละเอียดเพิ่มเติม เช่น ยี่ห้อ รุ่น ขนาด สี เป็นต้น
    total_qty INT NOT NULL,                      -- จำนวนทั้งหมด (ห้ามติดลบ)
    public_total_qty INT NOT NULL,               -- จำนวนที่อนุญาตให้บุคคลทั่วไปใช้งาน
    public_all BIT NOT NULL DEFAULT 0,           -- 1 = ใช้ได้ทุกคน 0 = เฉพาะสิทธิ์ที่กำหนด
    remark NVARCHAR(255) NULL,                   -- หมายเหตุ                                                                  
    create_by  NVARCHAR(50) null,                -- ผู้สร้างข้อมูล (อาจจะเป็น Admin หรือระบบอัตโนมัติ)
    create_date DATETIME NOT NULL,               -- วันที่สร้างข้อมูล
    update_by NVARCHAR(50) NULL,                 -- ผู้แก้ไขข้อมูลล่าสุด
    update_date DATETIME NULL,                   -- วันที่แก้ไขข้อมูลล่าสุด
    cancel_by NVARCHAR(50) NULL,                 -- ผู้ยกเลิกข้อมูล (Soft Delete)
    cancel_date DATETIME NULL,                   -- วันที่ยกเลิกข้อมูล (Soft Delete)
    FOREIGN KEY (id_hardware) REFERENCES ext26_assetcontrol_hardware(id_hardware)
   
);

CREATE INDEX IX_hardwarelog_hardware
ON ext26_assetcontrol_hardware_log(id_hardware);


/* =========================================================
   HARDWARE BORROW
   ระบบยืมอุปกรณ์ IT
========================================================= */
CREATE TABLE ext26_assetcontrol_hardware_borrow (
    id_borrow INT IDENTITY(1,1) PRIMARY KEY,          -- รหัสรายการยืม
    id_hardware INT NOT NULL,                         -- อุปกรณ์ที่ถูกยืม
    id_user INT NOT NULL,                             -- ผู้ยืม
    borrow_qty INT NOT NULL,                          -- จำนวนที่ยืม
    borrow_date DATETIME NOT NULL DEFAULT GETDATE(),  -- วันที่ยืม
    due_date DATETIME NOT NULL,                       -- วันที่กำหนดคืน
    return_date DATETIME NULL,                        -- วันที่คืนจริง
    borrow_status INT NOT NULL DEFAULT 1,             -- สถานะการยืม 1 = กำลังยืม, 2 = คืนแล้ว, 3 = เกินกำหนด
    remark NVARCHAR(255) NULL,                        -- หมายเหตุเพิ่มเติม
    create_by NVARCHAR(50) NULL,                      -- ผู้สร้างข้อมูล
    create_date DATETIME NOT NULL DEFAULT GETDATE(),  -- วันที่สร้างข้อมูล
    update_by NVARCHAR(50) NULL,                      -- ผู้แก้ไขข้อมูลล่าสุด
    update_date DATETIME NULL,                        -- วันที่แก้ไขข้อมูลล่าสุด
    cancel_by NVARCHAR(50) NULL,                      -- ผู้ยกเลิกข้อมูล
    cancel_date DATETIME NULL,                        -- วันที่ยกเลิกข้อมูล
    -- กฎคุณภาพข้อมูลการยืม
    CHECK (borrow_qty > 0),
    CHECK (due_date >= borrow_date),
    CHECK (return_date IS NULL OR return_date >= borrow_date),
    FOREIGN KEY (id_hardware) REFERENCES ext26_assetcontrol_hardware(id_hardware),
    FOREIGN KEY (id_user) REFERENCES ext26_assetcontrol_user(id_user),
    FOREIGN KEY (borrow_status) REFERENCES ext26_assetcontrol_borrow_status(id_status)
);


CREATE TABLE ext26_assetcontrol_hardware_borrow_log (
    id_borrow_log INT IDENTITY(1,1) PRIMARY KEY,      -- รหัสประวัติการยืม
    id_borrow INT NOT NULL,                           -- อ้างอิงรายการยืมหลัก
    id_hardware INT NOT NULL,                         -- อุปกรณ์ที่ถูกยืม
    id_user INT NOT NULL,                             -- ผู้ยืม
    borrow_qty INT NOT NULL,                          -- จำนวนที่ยืม
    borrow_date DATETIME NOT NULL DEFAULT GETDATE(),  -- วันที่ยืม
    due_date DATETIME NOT NULL,                       -- วันที่กำหนดคืน
    return_date DATETIME NULL,                        -- วันที่คืนจริง
    borrow_status INT NOT NULL DEFAULT 1,             -- สถานะการยืม 1 = กำลังยืม, 2 = คืนแล้ว, 3 = เกินกำหนด
    remark NVARCHAR(255) NULL,                        -- หมายเหตุเพิ่มเติม
    create_by NVARCHAR(50) NULL,                      -- ผู้สร้างข้อมูล
    create_date DATETIME NOT NULL DEFAULT GETDATE(),  -- วันที่สร้างข้อมูล
    update_by NVARCHAR(50) NULL,                      -- ผู้แก้ไขข้อมูลล่าสุด
    update_date DATETIME NULL,                        -- วันที่แก้ไขข้อมูลล่าสุด
    cancel_by NVARCHAR(50) NULL,                      -- ผู้ยกเลิกข้อมูล
    cancel_date DATETIME NULL,                        -- วันที่ยกเลิกข้อมูล
    -- กฎคุณภาพข้อมูลการยืม (สำหรับประวัติ)
    CHECK (borrow_qty > 0),
    CHECK (due_date >= borrow_date),
    CHECK (return_date IS NULL OR return_date >= borrow_date),
    FOREIGN KEY (id_borrow) REFERENCES ext26_assetcontrol_hardware_borrow(id_borrow),
    FOREIGN KEY (id_hardware) REFERENCES ext26_assetcontrol_hardware(id_hardware),
    FOREIGN KEY (id_user) REFERENCES ext26_assetcontrol_user(id_user),
    FOREIGN KEY (borrow_status) REFERENCES ext26_assetcontrol_borrow_status(id_status)
);

-- สร้างดัชนีหลัง CREATE TABLE เพื่อให้สคริปต์รันได้ตามลำดับ
CREATE INDEX IX_hardware_borrow_hardware
ON ext26_assetcontrol_hardware_borrow(id_hardware);

CREATE INDEX IX_hardware_borrow_user
ON ext26_assetcontrol_hardware_borrow(id_user);

CREATE INDEX IX_hardware_borrow_status
ON ext26_assetcontrol_hardware_borrow(borrow_status);

/* =========================================================
    SOFTWARE MASTER
    เก็บข้อมูลซอฟต์แวร์ที่มีอยู่ทั้งหมด
========================================================= */
CREATE TABLE ext26_assetcontrol_software (
    id_software INT IDENTITY(1,1) PRIMARY KEY,          -- รหัสเฉพาะของซอฟต์แวร์ (Auto Running ID)
    name_software NVARCHAR(255) NOT NULL UNIQUE,        --  เพิ่ม UNIQUE
    license NVARCHAR(100) NOT NULL ,                    -- ประเภท License เช่น OEM / Volume / Freeware
    detail_software NVARCHAR(MAX) NULL,                 -- รายละเอียดเพิ่มเติม
    url_software NVARCHAR(MAX) NULL,                    -- ลิงก์ดาวน์โหลดหรือข้อมูลอ้างอิง
    remark NVARCHAR(255) NULL,                          -- หมายเหตุเพิ่มเติม
    create_by  NVARCHAR(50) null,                       -- ผู้สร้างข้อมูล (อาจจะเป็น Admin หรือระบบอัตโนมัติ)
    create_date DATETIME NOT NULL,                      -- วันที่สร้างข้อมูล
    update_by NVARCHAR(50) NULL,                        -- ผู้แก้ไขข้อมูลล่าสุด
    update_date DATETIME NULL,                          -- วันที่แก้ไขข้อมูลล่าสุด
    cancel_by NVARCHAR(50) NULL,                        -- ผู้ยกเลิกข้อมูล (Soft Delete)
    cancel_date DATETIME NULL,                          -- วันที่ยกเลิกข้อมูล (Soft Delete)
);


/* =========================================================
   เครื่องจริงที่มี Asset Number
========================================================= */
CREATE TABLE ext26_assetcontrol_asset(
    id_asset INT IDENTITY(1,1) PRIMARY KEY,
    asset_number NVARCHAR(50) NOT NULL UNIQUE,          -- เลขทรัพย์สินของบริษัท (เลขหลักของระบบ) สร้าง QR Token อัตโนมัติ
    serial_number NVARCHAR(100) NULL UNIQUE,            -- เลขซีเรียลต้องไม่ซ้ำกัน (ถ้ามี)
    id_com_spec INT NOT NULL,                           -- อ้างอิงสเปค
    id_status INT NOT NULL DEFAULT 1,                   -- สถานะปัจจุบัน (1=พร้อมใช้งาน)
    dept NVARCHAR(50) NOT NULL,                         -- จาก HR DB
    remark NVARCHAR (255) NULL,                         -- หมายเหตุ
    create_by  NVARCHAR(50) null,                       -- ผู้สร้างข้อมูล (อาจจะเป็น Admin หรือระบบอัตโนมัติ)
    create_date DATETIME NOT NULL,                      -- วันที่สร้างข้อมูล
    update_by NVARCHAR(50) NULL,                        -- ผู้แก้ไขข้อมูลล่าสุด
    update_date DATETIME NULL,                          -- วันที่แก้ไขข้อมูลล่าสุด
    cancel_by NVARCHAR(50) NULL,                        -- ผู้ยกเลิกข้อมูล (Soft Delete)
    cancel_date DATETIME NULL,                          -- วันที่ยกเลิกข้อมูล (Soft Delete)
    FOREIGN KEY (id_com_spec) REFERENCES ext26_assetcontrol_computer_spec(id_com_spec),
    FOREIGN KEY (id_status) REFERENCES ext26_assetcontrol_status(id_status)
);

CREATE TABLE ext26_assetcontrol_asset_log(
    id_asset_log INT IDENTITY(1,1) PRIMARY KEY,
    id_asset INT NOT NULL,                              -- เครื่องจริงที่มี Asset Number
    asset_number NVARCHAR(50) NOT NULL,          -- เลขทรัพย์สินของบริษัท (เลขหลักของระบบ) สร้าง QR Token อัตโนมัติ
    serial_number NVARCHAR(100) NULL,            -- เลขซีเรียลต้องไม่ซ้ำกัน (ถ้ามี)
    id_com_spec INT NOT NULL,                           -- อ้างอิงสเปค
    id_status INT NOT NULL DEFAULT 1,                   -- สถานะปัจจุบัน (1=พร้อมใช้งาน)
    dept NVARCHAR(50) NOT NULL,                         -- จาก HR DB
    remark NVARCHAR (255) NULL,                         -- หมายเหตุ
    create_by  NVARCHAR(50) null,                       -- ผู้สร้างข้อมูล (อาจจะเป็น Admin หรือระบบอัตโนมัติ)
    create_date DATETIME NOT NULL,                      -- วันที่สร้างข้อมูล
    update_by NVARCHAR(50) NULL,                        -- ผู้แก้ไขข้อมูลล่าสุด
    update_date DATETIME NULL,                          -- วันที่แก้ไขข้อมูลล่าสุด
    cancel_by NVARCHAR(50) NULL,                        -- ผู้ยกเลิกข้อมูล (Soft Delete)
    cancel_date DATETIME NULL,                          -- วันที่ยกเลิกข้อมูล (Soft Delete)
    FOREIGN KEY (id_com_spec) REFERENCES ext26_assetcontrol_computer_spec(id_com_spec),
    FOREIGN KEY (id_status) REFERENCES ext26_assetcontrol_status(id_status)
);
/* =========================================================
   ASSET BORROW
   ระบบยืม Asset เช่น Computer
========================================================= */
CREATE TABLE ext26_assetcontrol_asset_borrow (
    id_asset_borrow INT IDENTITY(1,1) PRIMARY KEY,
    id_asset INT NOT NULL,                              -- เครื่องที่ถูกยืม
    id_user INT NOT NULL,                               -- ผู้ยืม
    borrow_date DATETIME NOT NULL DEFAULT GETDATE(),    -- วันที่ยืม (กำหนดค่าเริ่มต้นเป็นวันที่ปัจจุบัน)
    due_date DATETIME NOT NULL,                         -- วันกำหนดคืน
    return_date DATETIME NULL,                          -- วันที่คืนจริง
    borrow_status INT NOT NULL DEFAULT 1,               -- สถานะการยืม 1 = กำลังยืม, 2 = คืนแล้ว, 3 = เกินกำหนด
    remark NVARCHAR(255) NULL,                          -- หมายเหตุเพิ่มเติม    
    create_by  NVARCHAR(50) null,                       -- ผู้สร้างข้อมูล (อาจจะเป็น Admin หรือระบบอัตโนมัติ)
    create_date DATETIME NOT NULL,                      -- วันที่สร้างข้อมูล
    update_by NVARCHAR(50) NULL,                        -- ผู้แก้ไขข้อมูลล่าสุด
    update_date DATETIME NULL,                          -- วันที่แก้ไขข้อมูลล่าสุด
    cancel_by NVARCHAR(50) NULL,                        -- ผู้ยกเลิกข้อมูล (Soft Delete)
    cancel_date DATETIME NULL,                          -- วันที่ยกเลิกข้อมูล (Soft Delete)
    -- กฎคุณภาพข้อมูลการยืม
    CHECK (due_date >= borrow_date),
    CHECK (return_date IS NULL OR return_date >= borrow_date),
    FOREIGN KEY (id_asset) REFERENCES ext26_assetcontrol_asset(id_asset),
    FOREIGN KEY (id_user) REFERENCES ext26_assetcontrol_user(id_user),
    FOREIGN KEY (borrow_status) REFERENCES ext26_assetcontrol_borrow_status(id_status)
);


CREATE TABLE ext26_assetcontrol_asset_borrow_log (
    id_asset_borrow_log INT IDENTITY(1,1) PRIMARY KEY,
    id_asset_borrow INT NOT NULL,                       -- อ้างอิงจากตาราง borrow
    id_asset INT NOT NULL,                              -- เครื่องที่ถูกยืม
    id_user INT NOT NULL,                               -- ผู้ยืม
    borrow_date DATETIME NOT NULL DEFAULT GETDATE(),    -- วันที่ยืม (กำหนดค่าเริ่มต้นเป็นวันที่ปัจจุบัน)
    due_date DATETIME NOT NULL,                         -- วันกำหนดคืน
    return_date DATETIME NULL,                          -- วันที่คืนจริง
    borrow_status INT NOT NULL DEFAULT 1,               -- สถานะการยืม 1 = กำลังยืม, 2 = คืนแล้ว, 3 = เกินกำหนด
    remark NVARCHAR(255) NULL,                          -- หมายเหตุเพิ่มเติม
    create_by  NVARCHAR(50) null,                       -- ผู้สร้างข้อมูล (อาจจะเป็น Admin หรือระบบอัตโนมัติ)
    create_date DATETIME NOT NULL,                      -- วันที่สร้างข้อมูล
    update_by NVARCHAR(50) NULL,                        -- ผู้แก้ไขข้อมูลล่าสุด
    update_date DATETIME NULL,                          -- วันที่แก้ไขข้อมูลล่าสุด
    cancel_by NVARCHAR(50) NULL,                        -- ผู้ยกเลิกข้อมูล (Soft Delete)
    cancel_date DATETIME NULL,                          -- วันที่ยกเลิกข้อมูล (Soft Delete)
    -- กฎคุณภาพข้อมูลการยืม (สำหรับประวัติ)
    CHECK (due_date >= borrow_date),
    CHECK (return_date IS NULL OR return_date >= borrow_date),
    FOREIGN KEY (id_asset_borrow) REFERENCES ext26_assetcontrol_asset_borrow(id_asset_borrow),
    FOREIGN KEY (id_asset) REFERENCES ext26_assetcontrol_asset(id_asset),
    FOREIGN KEY (id_user) REFERENCES ext26_assetcontrol_user(id_user),
    FOREIGN KEY (borrow_status) REFERENCES ext26_assetcontrol_borrow_status(id_status)
);

/* =========================================================
   ASSET OWNER HISTORY
   เก็บประวัติการถือครองย้อนหลัง
========================================================= */
CREATE TABLE ext26_assetcontrol_asset_owner(
    id_owner INT IDENTITY(1,1) PRIMARY KEY,             -- รหัสหลักของการถือครอง
    id_asset INT NOT NULL,                              -- เครื่องที่ถูกถือครอง   
    id_user INT NOT NULL,                               -- ผู้ถือครองในช่วงเวลานั้น
    start_date DATETIME NOT NULL DEFAULT GETDATE(),     -- วันที่เริ่มถือครอง (กำหนดค่าเริ่มต้นเป็นวันที่ปัจจุบัน)
    end_date DATETIME NULL,                             -- ถ้า NULL = ยังถือครองอยู่
    FOREIGN KEY (id_asset) REFERENCES ext26_assetcontrol_asset(id_asset),
    FOREIGN KEY (id_user) REFERENCES ext26_assetcontrol_user(id_user)
);

CREATE TABLE ext26_assetcontrol_tran_status(
    id_tran_status INT PRIMARY KEY,                      -- รหัสสถานะการโอนย้าย เช่น 1, 2, 3, 4
    status_name NVARCHAR(50) NOT NULL UNIQUE             -- ชื่อสถานะการโอนย้าย เช่น Pending, Approved, Rejected, Cancelled UNIQUE = ห้ามชื่อซ้ำ
);


INSERT INTO ext26_assetcontrol_tran_status VALUES
(1,'Pending'),
(2,'Approved'),
(3,'Rejected'),
(4,'Cancelled');

CREATE TABLE ext26_assetcontrol_computer_tran(
    id_computer_tran INT IDENTITY(1,1) PRIMARY KEY,
    id_asset INT NOT NULL,                      -- เครื่องที่ถูกย้าย
    id_tran_status INT NOT NULL DEFAULT 1,      -- สถานะการโอนย้าย 1 = รอดำเนินการ 2 = อนุมัติ 3 = ไม่อนุมัติ 4 = ยกเลิก
    old_dept_id INT NULL,                       -- แผนกเดิม
    new_dept_id INT NULL,                       -- แผนกใหม่
    old_user_id INT NULL,                       -- ผู้ใช้เดิม
    new_user_id INT NULL,                       -- ผู้ใช้ใหม่
    tran_type NVARCHAR(50),                     -- Transfer / Change User
    remark NVARCHAR(255) NULL,                  -- หมายเหตุเพิ่มเติม
    create_by  NVARCHAR(50) null,               -- ผู้สร้างข้อมูล (อาจจะเป็น Admin หรือระบบอัตโนมัติ)
    create_date DATETIME NOT NULL,              -- วันที่สร้างข้อมูล
    update_by NVARCHAR(50) NULL,                -- ผู้แก้ไขข้อมูลล่าสุด
    update_date DATETIME NULL,                  -- วันที่แก้ไขข้อมูลล่าสุด
    cancel_by NVARCHAR(50) NULL,                -- ผู้ยกเลิกข้อมูล (Soft Delete)
    cancel_date DATETIME NULL,                  -- วันที่ยกเลิกข้อมูล (Soft Delete)       
    FOREIGN KEY (id_asset) REFERENCES ext26_assetcontrol_asset(id_asset),
    FOREIGN KEY (old_dept_id) REFERENCES ext26_assetcontrol_department(id_dept),
    FOREIGN KEY (new_dept_id) REFERENCES ext26_assetcontrol_department(id_dept),
    FOREIGN KEY (old_user_id) REFERENCES ext26_assetcontrol_user(id_user),
    FOREIGN KEY (new_user_id) REFERENCES ext26_assetcontrol_user(id_user),
    FOREIGN KEY (id_tran_status) REFERENCES ext26_assetcontrol_tran_status(id_tran_status)
);

CREATE TABLE ext26_assetcontrol_approve_status(
    id_approve_status INT PRIMARY KEY,          -- รหัสสถานะการอนุมัติ เช่น 1, 2, 3
    status_name NVARCHAR(50) NOT NULL UNIQUE    -- ชื่อสถานะการอนุมัติ เช่น Pending, Approved, Rejected UNIQUE = ห้ามชื่อซ้ำ
);

INSERT INTO ext26_assetcontrol_approve_status (id_approve_status, status_name)
VALUES
(1,'Pending'),
(2,'Approved'),
(3,'Rejected');

CREATE TABLE ext26_assetcontrol_approve(
    id_approve INT IDENTITY(1,1) PRIMARY KEY,
    emp_id NVARCHAR(50) NOT NULL,           -- รหัสพนักงานจาก HR ที่ต้องอนุมัติ
    id_computer_tran INT NOT NULL,          -- รายการโอนเครื่อง
    approve_ind INT NOT NULL,               -- ลำดับการอนุมัติ 1 2 3
    approve_status INT NOT NULL DEFAULT 1,  -- 1 = รออนุมัติ 2 = อนุมัติ 3 = ไม่อนุมัติ  1 = Pending 2 = Approved 3 = Rejected
    remark NVARCHAR (255) NULL,             -- comment
    approved_by NVARCHAR(50) NULL,          -- คนที่กด approve
    approve_date DATETIME NULL,             -- วันที่ approve
    cancel_by NVARCHAR(50) NULL,            -- ผู้แก้ไขข้อมูลแผนกล่าสุด
    cancel_date DATETIME NULL,              -- วันที่แก้ไขข้อมูลแผนกล่าสุด
    FOREIGN KEY (id_computer_tran) REFERENCES ext26_assetcontrol_computer_tran(id_computer_tran),
    FOREIGN KEY (approve_status) REFERENCES ext26_assetcontrol_approve_status(id_approve_status)
    );

CREATE TABLE ext26_assetcontrol_approve_log(
    id_approve_log INT IDENTITY(1,1) PRIMARY KEY,
    id_approve INT NOT NULL,                 -- รหัสหลักของการอนุมัติ
    emp_id NVARCHAR(50) NOT NULL,           -- รหัสพนักงานจาก HR
    id_computer_tran INT NOT NULL,          -- รายการโอนเครื่อง
    approve_ind INT NOT NULL,               -- ลำดับการอนุมัติ 1 2 3
    approve_status INT NOT NULL DEFAULT 1,  -- 1 = รออนุมัติ 2 = อนุมัติ 3 = ไม่อนุมัติ  1 = Pending 2 = Approved 3 = Rejected
    remark NVARCHAR (255) NULL,             -- comment
    approved_by NVARCHAR(50) NULL,          -- คนที่กด approve
    approve_date DATETIME NULL,             -- วันที่ approve
    cancel_by NVARCHAR(50) NULL,            -- ผู้แก้ไขข้อมูลแผนกล่าสุด
    cancel_date DATETIME NULL,              -- วันที่แก้ไขข้อมูลแผนกล่าสุด
    FOREIGN KEY (id_approve) REFERENCES ext26_assetcontrol_approve(id_approve)
    );





/* =========================================================
    ASSET IMAGE
   ตารางเก็บรูปแยกจาก Asset
   1 เครื่องมีหลายรูปได้
========================================================= */
CREATE TABLE ext26_assetcontrol_asset_image(
    id_image INT IDENTITY(1,1) PRIMARY KEY,
    id_asset INT NOT NULL,                     -- รูปนี้เป็นของเครื่องไหน
    image_name NVARCHAR(255) NOT NULL,         -- ชื่อไฟล์
    image_path NVARCHAR(500) NOT NULL,         -- ที่อยู่ไฟล์บน Server
    image_type NVARCHAR(50) NULL,              -- ประเภท เช่น Before / After / Damage 
    FOREIGN KEY (id_asset) REFERENCES ext26_assetcontrol_asset(id_asset)
);



/* =========================================================
   INDEX เพื่อเพิ่มความเร็ว
========================================================= */
CREATE INDEX IX_asset_status ON ext26_assetcontrol_asset(id_status);
CREATE INDEX IX_asset_comspec ON ext26_assetcontrol_asset(id_com_spec);
CREATE INDEX IX_owner_asset ON ext26_assetcontrol_asset_owner(id_asset);
CREATE INDEX IX_owner_user ON ext26_assetcontrol_asset_owner(id_user);
CREATE INDEX IX_transfer_asset ON ext26_assetcontrol_computer_tran(id_asset);
CREATE INDEX IX_approve_tran ON ext26_assetcontrol_approve(id_computer_tran);
CREATE INDEX IX_asset_borrow_asset ON ext26_assetcontrol_asset_borrow(id_asset);
CREATE INDEX IX_asset_borrow_user ON ext26_assetcontrol_asset_borrow(id_user);
CREATE INDEX IX_asset_borrow_status ON ext26_assetcontrol_asset_borrow(borrow_status);



