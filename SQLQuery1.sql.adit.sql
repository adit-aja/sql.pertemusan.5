USE DBAlineashift1;

--DML & TABEL KHUSUS
--DML (AFTER /FOR) & TABEL INSERTED
CREATE OR ALTER TRIGGER trg_TUnit_AuditInsert
ON TUnit
AFTER INSERT 
AS
BEGIN 
	SET NOCOUNT ON;--menyembunyikan masage
	SELECT 
		KodeWil AS KodeBaru,
		Deskripsi AS DeskripsiBaru,
		Koordinator AS KoordinarorBaru
		FROM inserted;
END;
--uji coba
INSERT INTO TUnit VALUES ('A001','Buku Gramedia','Ipit'),('A0032','Buku Gramedia','Suryo');

--DML (AFTER /FOR) & TABEL DELETED

CREATE OR ALTER TRIGGER trg_TUnit_AuditInsert
ON TUnit
AFTER DELETE
AS
BEGIN 
	SET NOCOUNT ON;--menyembunyikan masage
	SELECT 
		KodeWil AS Kodehapus,
		Deskripsi AS Deskripsihapus
		
		FROM deleted;
END;
--Uji coba
DELETE FROM TUnit WHERE KodeWil='A001';

--DML (AFTER /FOR) & TABEL INSERTED & DELETED
CREATE OR ALTER TRIGGER trg_TUnit_AuditInsert
ON TUnit
AFTER UPDATE
AS
BEGIN 
	SET NOCOUNT ON;
	--membandingkan data baru dan data lama 
	SELECT 
	d.KodeWil,
	d.Deskripsi AS DeskripsiLama,
	i.Deskripsi AS DeskripsiBaru,
	d.Koordinator AS KoordinarorLama,
	i.Koordinator AS KoordinarorBaru
	FROM deleted d
	INNER JOIN inserted i ON d.KodeWil = i.KodeWil;
END;
--uji coba 
UPDATE TUnit SET Deskripsi = 'Toko Buru Baru' WHERE KodeWil='A003';
UPDATE TUnit SET Koordinator = 'Suryo' WHERE KodeWil='A003';

--DML (INSTEAD /OF) 
--membuat view yang mengabungkan informasi buku (TMasterBuku)
--dan stock (TDtailMasterBuku)
CREATE OR ALTER VIEW vw_StockBukuTrigger
AS
SELECT
	m.IDBuku,
	m.JudulBuku,
	d.UNIT,
	d.Instock
	FROM TMasterbuku as m
	INNER JOIN TDetailMasterBukuUnit AS d
	ON m.IDBuku = d.IDBuku;
	--menjakanka VIEW
	SELECT * FROM vw_StockBukuTrigger;

	--membuat trigger
	CREATE OR ALTER TRIGGER trg_CegahHapusStok
	ON vw_StockBukuTrigger
	INSTEAD OF DELETE 
	AS 
	BEGIN
		SET NOCOUNT ON
		PRINT 'Penghapusan Data Tidak Diijinkan';
	END;

	--uji coba
	DELETE FROM vw_StockBukuTrigger WHERE IDBuku = 1;
	SELECT * FROM vw_StockBukuTrigger WHERE IDBuku =1;

--DDL 
--mencegah menghapus tabel
CREATE OR ALTER TRIGGER trg_DropTabel
ON DATABASE
FOR DROP_TABLE
AS 
BEGIN
	SET NOCOUNT ON;
	PRINT 'aksitersebut ditolat';
	ROLLBACK;
END;

DROP TABLE dbo.SUKABUKU;

CREATE OR ALTER TRIGGER trg_CegahHapus
	ON TUnit
	INSTEAD OF UPDATE 
	AS 
	BEGIN
		SET NOCOUNT ON
		PRINT 'Penghapusan Data Tidak Diijinkan';
		ROLLBACK;
	END;

	UPDATE TUnit SET Deskripsi = 'Toko Buru Baru' WHERE KodeWil='A003';




