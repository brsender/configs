UPDATE WSINFO
SET empidnum = 
CASE WHEN LEN(RTRIM(EmpIdNum)) = 1 THEN '000000' + empidnum 
     WHEN LEN(RTRIM(EmpIdNum)) = 2 THEN '00000' + empidnum
     WHEN LEN(RTRIM(EmpIdNum)) = 3 THEN '0000' + empidnum
     WHEN LEN(RTRIM(EmpIdNum)) = 4 THEN '000' + empidnum
     WHEN LEN(RTRIM(EmpIdNum)) = 5 THEN '00' + empidnum
     WHEN LEN(RTRIM(EmpIdNum)) = 6 THEN '0' + empidnum
END
WHERE empidnum IN 
(SELECT RTRIM(EmpIdNum)
FROM dbo.WSInfo
WHERE (LEN(RTRIM(EmpIdNum)) <= 6) AND (ISNUMERIC(EmpIdNum) = 1))
AND mtgid = 183
