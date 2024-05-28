CREATE DATABASE kardexProject;
GO
USE kardexProject;
GO
use master


CREATE TABLE  personas(
	idpersona 	INT  PRIMARY KEY IDENTITY(1,1),
	apepaterno	VARCHAR(120)	NOT NULL,
	apematerno	VARCHAR(120)	NOT NULL,
	nombres 	VARCHAR(120)	NOT NULL,
	tipodoc		CHAR(3)			NOT NULL,	-- uk
	nrodocumento	CHAR(11)		NOT NULL,	--uk
	telefono 	CHAR(9)			NULL, -- opcional

	create_at   DATETIME		NOT NULL DEFAULT GETDATE(),
	update_at   DATETIME		NULL,
	inactive_at DATETIME		NULL,

	CONSTRAINT ck_tipodoc_per		CHECK (tipodoc IN ('DNI','CEX')), -- DNI->documento nacional de Identidad --CEX->carnet de extranjeria
	CONSTRAINT uk_nrdocumento_per	UNIQUE(nrodocumento),
	CONSTRAINT ck_nrdocumento_per	CHECK((nrodocumento = 'DNI' AND LEN(nrodocumento) = 8) OR (nrodocumento = 'CEX' AND LEN(nrodocumento) = 11)),

	CONSTRAINT ck_telefono_per		CHECK (telefono IS NULL OR LEN(telefono)=9)
);
GO
 -- esta parte creo que es similar a los roles ya que se puede manejar desde una sola tabla
CREATE TABLE permisos(
	idpermiso	INT PRIMARY KEY IDENTITY(1,1),
	permiso     VARCHAR(50),
CONSTRAINT uk_permisos UNIQUE(permiso)
);
GO
CREATE TABLE roles
(
	idrol		INT PRIMARY KEY IDENTITY(1,1),
	rol			CHAR(3),
CONSTRAINT uk_unique UNIQUE(rol)
);
GO
--roles_permisos, nos permite insertar mas de un permiso en un mismo rol,
--roles y permisos son tablas de muchos a muchos.
CREATE TABLE roles_permisos(
	idpermiso   INT NOT NULL,
	idrol       INT NOT NULL,
PRIMARY KEY (idpermiso,idrol),
CONSTRAINT fk_idpermisos FOREIGN KEY (idpermiso)REFERENCES permisos(idpermiso),
CONSTRAINT fk_idroles FOREIGN KEY (idrol)REFERENCES roles(idrol),
);
GO

CREATE TABLE usuarios(
	idusuario	INT PRIMARY KEY IDENTITY(1,1),
	idpersona	INT          NOT NULL,
	email		VARCHAR(150) NOT NULL,
	passuser	VARCHAR(70)	 NOT NULL,
	create_at   DATETIME     NOT NULL DEFAULT GETDATE(),
	update_at   DATETIME     NULL,
	inactive_at DATETIME     NUll,
CONSTRAINT fk_idpersona FOREIGN KEY (idpersona) REFERENCES personas(idpersona),
CONSTRAINT uk_email     UNIQUE(email)
);
GO
-- son tablas de muchos a muchos 
CREATE TABLE rol_usuarios(
	idrol		INT NOT NULL,
	idusuario   INT NOT NULL,
	PRIMARY KEY(idrol,idusuario),
CONSTRAINT fk_idrol_U FOREIGN KEY(idrol)REFERENCES roles(idrol),
CONSTRAINT fk_idusuario_U FOREIGN KEY(idusuario)REFERENCES usuarios(idusuario),
);
GO

CREATE TABLE tipoproveedores(
	idtiproveedor	INT PRIMARY KEY IDENTITY(1,1),
	tipoproveedor   VARCHAR(50)  NOT NULL,
CONSTRAINT uk_tipoproveedor UNIQUE(tipoproveedor)
);
GO
CREATE TABLE marcas(
	idmarca		INT PRIMARY KEY IDENTITY(1,1),
	marca       VARCHAR(70)  NOT NULL,
CONSTRAINT uk_marca  UNIQUE(marca)
);
GO
CREATE TABLE proveedores(
	idproveedor		INT PRIMARY  KEY IDENTITY(1,1),
	idtiproveedor   INT             NOT NULL,
	razonsocial		VARCHAR(250)	NOT NULL,
	tipoproveedor	CHAR(3)         NOT NULL,  -- EMP Empresa o PJR persona juridica
	ruc			    CHAR(11)	    NOT NULL,
	direccion       VARCHAR(70)	    NOT NULL,
	telefono		CHAR(9)         NOT NULL,
	email			VARCHAR(150)    NOT NULL,
	create_at       DATETIME        NOT NULL DEFAULT GETDATE(),
	update_at       DATETIME        NULL,
	inactive_at     DATETIME        NULL,
CONSTRAINT fk_idtiproveedor FOREIGN KEY (idtiproveedor)REFERENCES tipoproveedores(idtiproveedor),
CONSTRAINT uk_razonsocial   UNIQUE(razonsocial),
CONSTRAINT uk_ruc		    UNIQUE(ruc),
CONSTRAINT uk_telefonoP     UNIQUE(telefono),
CONSTRAINT uk_emailP		UNIQUE(email),
CONSTRAINT ck_tipoproveedor CHECK (tipoproveedor IN ('EMP','PJR')),
CONSTRAINT ck_ruc		    CHECK (ruc LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
CONSTRAINT ck_telefonoP	    CHECK (telefono LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);
GO
-- marcas y prove... tablas de muchos a muchos.
CREATE TABLE marcas_proveedores(
	idmarca		INT NOT NULL,
	idproveedor INT NOT NULL,
	PRIMARY  KEY (idmarca,idproveedor),
CONSTRAINT fk_idmarcas FOREIGN KEY(idmarca) REFERENCES marcas(idmarca),
CONSTRAINT fk_idproveedores FOREIGN KEY(idproveedor) REFERENCES proveedores(idproveedor),
);

CREATE TABLE clientes(
	idcliente   INT PRIMARY KEY IDENTITY(1,1),
	nrdocumento CHAR(8)     NOT NULL,  --Podria usar una api, 
	apellidos   VARCHAR(50) NOT NULL,  --para completar esos datos
	nombres     VARCHAR(50) NOT NULL,
CONSTRAINT uk_nrdocumentoC  UNIQUE(nrdocumento)
);
GO

CREATE TABLE categorias(
	idcategoria		INT PRIMARY KEY IDENTITY(1,1),
	categoria		VARCHAR(70) NOT NULL,
    create_at       DATETIME    NOT NULL DEFAULT GETDATE(),
	inactive_at     DATETIME    NULL
);
GO

CREATE TABLE subcategorias(
	idsubcategoria	INT PRIMARY KEY IDENTITY(1,1),
	idcategoria     INT NOT NULL,
	subcategoria    VARCHAR(70),
CONSTRAINT fk_categoria	FOREIGN KEY (idcategoria) REFERENCES categorias(idcategoria)
);
GO



CREATE TABLE productos(
	idproducto		INT PRIMARY KEY IDENTITY(1,1),
	idproveedor		INT				NOT NULL,
	idsubcategoria  INT				NOT NULL,
	producto		VARCHAR(60)		NOT NULL,
	descripcion     VARCHAR(300)	NOT NULL,
	modelo			CHAR(10)		NOT NULL, --autogenerado, por subcategoria y nombre del producto
	precio          DECIMAL(10,2)	NOT NULL,
	create_at       DATETIME		NOT NULL DEFAULT GETDATE(),
	update_at       DATETIME		NULL,
	inactive_at     DATETIME		NULL,
CONSTRAINT uk_modelo UNIQUE(modelo),
CONSTRAINT fk_idproveedor    FOREIGN KEY (idproveedor)   REFERENCES proveedores(idproveedor),
CONSTRAINT fk_idsubcategoria FOREIGN KEY (idsubcategoria)REFERENCES subcategorias(idsubcategoria)
);
GO

CREATE TABLE kardex(
	idalmacen      INT PRIMARY KEY IDENTITY(1,1),
	idproducto     INT NOT NULL,
	idusuario      INT NOT NULL,
	idcliente      INT NULL,
	tipomovimiento VARCHAR(10) NOT NULL,
	stock          INT NOT NULL,
	cantidad       INT NOT NULL,
	create_at      DATETIME NOT NULL DEFAULT GETDATE(),

CONSTRAINT fk_idproducto  FOREIGN KEY (idproducto) REFERENCES productos(idproducto),
CONSTRAINT fk_idusuario   FOREIGN KEY (idusuario)  REFERENCES usuarios(idusuario),
CONSTRAINT fk_idcliente   FOREIGN KEY (idcliente)  REFERENCES clientes(idcliente),
CONSTRAINT ck_tmovimietno CHECK (tipomovimiento IN ('Entrada','Salida')),
CONSTRAINT uk_stock       CHECK (stock>=0),
CONSTRAINT uk_cantidad    CHECK (cantidad>0)
);
GO

