-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.inventario (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  producto_id bigint,
  stock integer,
  CONSTRAINT inventario_pkey PRIMARY KEY (id),
  CONSTRAINT stock_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id)
);
CREATE TABLE public.medio_pago (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  medio_pago character varying UNIQUE,
  CONSTRAINT medio_pago_pkey PRIMARY KEY (id)
);
CREATE TABLE public.productos (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  nombre character varying,
  precio_compra_unidad numeric,
  iva_19 numeric,
  iva_30 numeric,
  precio_recomendado numeric,
  precio_venta integer,
  fecha_insert timestamp without time zone DEFAULT now(),
  margen_ganancia numeric,
  codigo_barras character varying,
  CONSTRAINT productos_pkey PRIMARY KEY (id)
);
CREATE TABLE public.venta_producto (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  venta_id bigint,
  producto_id bigint,
  cantidad smallint,
  valor numeric,
  CONSTRAINT venta_producto_pkey PRIMARY KEY (id),
  CONSTRAINT venta_producto_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id),
  CONSTRAINT venta_producto_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES public.ventas(id)
);
CREATE TABLE public.ventas (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  valor_total_venta numeric,
  medio_pago_id bigint,
  valor_pago_tarjeta_credito numeric,
  cantidad_productos smallint,
  CONSTRAINT ventas_pkey PRIMARY KEY (id),
  CONSTRAINT ventas_medio_pago_id_fkey FOREIGN KEY (medio_pago_id) REFERENCES public.medio_pago(id)
);