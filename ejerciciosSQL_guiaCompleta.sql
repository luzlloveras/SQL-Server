use EMPRESA;
/*EJERCICIO 2 */
/*punto 1*/
select * from detalle_pedido;
alter table detalle_pedido add cantidad1 numeric(10);

/*punto2*/
select * from cliente;
alter table cliente add limite_credito money default(0);

/*punto 3*/
select * from lista;
alter table lista add constraint ganancia_porcentaje check(ganancia_porcentaje>0);

/*punto 4*/
select * from oficina;
alter table oficina add ciudad varchar(50);

/*punto 5*/
alter table oficina drop column ciudad;

/*punto 6*/
select * from pedido;
alter table pedido add fecha_entrega AS (fecha_pedido + 30);

/*EJERCICIO 3 */
select * from documento;
select * from oficina;
select * from empleado;
select * from datos_contrato;
select * from fabricante;
select * from lista;
select * from producto;
select * from cliente;
select * from pedido;


/*EJERCICIO 4*/
---------------consultas simples------------------------------------------------------

/* punto 1*/
select descripcion from oficina;

/* punto 2*/
select descripcion, precio_costo, (precio_costo + precio_costo * 21 / 100) as 'precio_con_IVA' from producto;

/*punto 3*/
select apellido, nombre, fecha_nacimiento, DATEDIFF(YEAR,fecha_nacimiento,GETDATE()) as Edad  from empleado;

/* punto 4*/
select * from empleado where codigo_jefe = 107;

/* punto 5*/
select * from empleado where nombre = 'Maria';

/* punto 6*/
select * from cliente where razon_social LIKE 'L%';

/* punto 7*/
select * from pedido where month(fecha_pedido) = 03 order by fecha_pedido;

/* punto 8*/
select * from oficina where codigo_director IS NULL;

/* punto 9*/
select top 4 descripcion, min(precio_costo) precio_minimo from producto group by descripcion, precio_costo;

/* punto 10*/
select top 3 codigo_empleado, max(cuota) max_cuota from datos_contrato group by codigo_empleado, cuota;
select codigo_empleado from (select top 3 codigo_empleado, max(cuota) max_cuota from datos_contrato group by codigo_empleado, cuota)as codigos

--------------------------------------------------------consultas multitabla-------------------------------------------------
--ejercicio 1
select p.descripcion, f.razon_social, s.cantidad
from producto as p
join fabricante as f
on p.codigo_fabricante = f.codigo_fabricante
join stock as s
on p.codigo_producto = s.codigo_producto
order by razon_social, descripcion;

--ejercicio 2
select p.codigo_pedido, p.fecha_pedido, e.apellido, c.razon_social
from pedido as p
join empleado as e
on p.codigo_empleado = e.codigo_empleado
join cliente as c
on p.codigo_cliente = c.codigo_cliente;

--ejercicio 3
select e.apellido as empleado, d.cuota as cuota_asignada, o.descripcion as oficina, e2.apellido as jefe
from empleado as e
join datos_contrato as d
on e.codigo_empleado = d.codigo_empleado
join oficina as o
on e.codigo_oficina = o.codigo_oficina
join empleado as e2
on e.codigo_jefe = e2.codigo_empleado 
order by cuota_asignada desc

--ejercicio 4
select distinct razon_social 
from cliente c, pedido p
where c.codigo_cliente = p.codigo_cliente 
and month(p.fecha_pedido) = 04;

--ejercicio 5
select distinct prod.descripcion 
from producto as prod
join detalle_pedido as det
on prod.codigo_producto = det.codigo_producto
join pedido as ped
on det.codigo_pedido = ped.codigo_pedido
and month(ped.fecha_pedido) = 03
order by descripcion;

--punto 6
select e.apellido, e.nombre, d.fecha_contrato, e.fecha_nacimiento, DATEDIFF(year,d.fecha_contrato,getdate()) AS Antiguedad
from empleado as e
join datos_contrato as d
on e.codigo_empleado = d.codigo_empleado and DATEDIFF(year,d.fecha_contrato,getdate())>=10
order by Antiguedad DESC

--punto 7
select c.razon_social, c.codigo_cliente, c.codigo_lista, descripcion, l.ganancia_porcentaje
from cliente c, lista l
where c.codigo_lista = l.codigo_lista and l.descripcion = 'Mayorista'
order by razon_social

--punto 8
select distinct c.razon_social,prod.descripcion
from cliente as c
join pedido as p
on c.codigo_cliente = p.codigo_cliente
join detalle_pedido as d
on d.codigo_pedido = p.codigo_pedido
join producto as prod
on prod.codigo_producto = d.codigo_producto
order by razon_social, descripcion

--punto9
select p.descripcion, s.pto_reposicion - s.cantidad as "cantidad a comprar", f.razon_social
from stock as s
join producto as p
on s.codigo_producto = p.codigo_producto
join fabricante as f
on f.codigo_fabricante = p.codigo_fabricante
where s.cantidad < s.pto_reposicion
order by razon_social, descripcion

--punto 10
select e.apellido, e.nombre,d.cuota
from empleado as e
join datos_contrato as d
on e.codigo_empleado = d.codigo_empleado 
and (d.cuota<50000 or d.cuota>100000)

----------------------------------------------- -Consultas de actualización de datos----------------------------------------------------------------
-- punto 1
select *
into aux_empleado 
from empleado

--punto 2
update precio_venta set precio = precio + prod.precio_costo * l.ganancia_porcentaje
from producto as prod
join precio_venta as pre
on prod.codigo_producto = pre.codigo_producto
join lista as l
on l.codigo_lista = pre.codigo_lista

--punto 3
delete fabricante from fabricante  
left join producto as p
on fabricante.codigo_fabricante = p.codigo_fabricante
where p.descripcion is null

--punto 4
delete cliente from cliente
left join pedido as p
on cliente.codigo_cliente = p.codigo_cliente
where p.codigo_pedido is null

--punto 5
update datos_contrato set cuota = cuota * 5 / 100 + cuota
where fecha_contrato < Convert(datetime, '01/01/1999')

--punto 6
update empleado set codigo_empleado = 112
where codigo_empleado = 110

--punto 7
select * into aux_producto from producto

--punto 8
update producto set precio_costo = precio_costo * 10 /100 + precio_costo

--punto 9
UPDATE producto
SET producto.precio_costo = aux_producto.precio_costo
FROM aux_producto

--punto 10
update stock
set pto_reposicion = 600
from producto p, fabricante f
where stock.codigo_producto = p.codigo_producto
and f.codigo_fabricante = p.codigo_fabricante
and f.razon_social = 'Tomasti Hnos.'
 
 ------------------------------------------------------------------------- consultas de resumen--------------------------------------------------------
 --punto 1
 select f.razon_social, avg(precio_costo) as "Precio Medio"
 from producto p, fabricante f
 where p.codigo_fabricante = f.codigo_fabricante
 and f.razon_social = 'ABC Comercial'
 group by razon_social

 --punto 2
 select f.razon_social, count(p.codigo_producto) as "Cantidad de productos"
 from producto p, fabricante f
 where p.codigo_fabricante = f.codigo_fabricante
 group by razon_social

 --punto 3
 select p.codigo_pedido, p.fecha_pedido, c.razon_social, sum(d.cantidad * prev.precio) as "Importe total"
 from pedido as p
 join detalle_pedido as d
 on d.codigo_pedido = p.codigo_pedido
 join cliente as c
 on p.codigo_cliente = c.codigo_cliente
 join precio_venta as prev
 on d.codigo_producto = prev.codigo_producto
 and c.codigo_lista = prev.codigo_lista
 group by p.codigo_pedido, p.fecha_pedido, c.razon_social

 --punto 4
 update datos_contrato
 set ventas = (select count(codigo_empleado)from pedido where pedido.codigo_empleado = datos_contrato.codigo_empleado)

--punto 5
select o.descripcion as "Oficina", count(e.codigo_oficina) as "Cantidad de empleados"
from empleado e, oficina o
where e.codigo_oficina = o.codigo_oficina
group by o.descripcion

--punto 6
select fecha_pedido as "Primer pedido" from pedido where codigo_pedido = 1

--punto 7
select avg(cuota)as "Cuota promedio", avg(ventas)as "Venta promedio" from datos_contrato

--punto 8 
select c.razon_social, count(p.codigo_cliente)
from pedido p, cliente c
where p.codigo_cliente = c.codigo_cliente
group by razon_social

--punto 9 
select distinct prod.descripcion, sum(d.cantidad) as "Cantidad pedida"
from detalle_pedido as d
join pedido as ped
on d.codigo_pedido = ped.codigo_pedido
and month(ped.fecha_pedido) = 03
join producto as prod
on prod.codigo_producto = d.codigo_producto
group by descripcion

--punto 10
select count(cantidad) as "Cantidad de productos con stock bajo"
from stock
where cantidad < pto_reposicion

-- Subconsultas
--punto 1
select c.razon_social as "Cliente que atendio Analia"
from empleado as e
join pedido as p
on e.codigo_empleado = p.codigo_empleado
join cliente as c
on p.codigo_cliente = c.codigo_cliente
where e.nombre =  'Analia' 
and e.apellido = 'Gonzales'

--punto 2
select e.apellido, e.nombre
from empleado as e
join oficina as o
on e.codigo_oficina = o.codigo_oficina
and o.descripcion <> 'Ventas Interior'

--punto 3
-- cantidad facturada en ventas por cada empleado que realizo pedidos
select  ped.codigo_empleado, sum(d.cantidad * v.precio) as "Cantidad facturada en pedidos por el empleado"
into pedidos_facturados_empleados
from pedido as ped
join detalle_pedido as d
on ped.codigo_pedido = d.codigo_pedido
join precio_venta as v
on d.codigo_producto = v.codigo_producto
join cliente as c
on ped.codigo_cliente = c.codigo_cliente
and v.codigo_lista = c.codigo_lista
group by codigo_empleado

-- empleados con pedidos que representan un 10% mas que su cuota
select d.codigo_empleado
into empleados_pedidos_10perCentMore_cuota
from datos_contrato as d
join pedidos_facturados_empleados as p
on d.codigo_empleado = p.codigo_empleado
where p.[Cantidad facturada en pedidos por el empleado] > (d.cuota + d.cuota * 10 / 100)

-- listado de oficinas con empleados con pedidos que representan un 10% mas que su cuota
select distinct o.descripcion
from oficina as o 
join empleado as e
on o.codigo_oficina = e.codigo_oficina
join empleados_pedidos_10perCentMore_cuota as ep
on e.codigo_empleado = ep.codigo_empleado

--punto 4
select distinct p.descripcion as "Productos"
from producto as p 
join detalle_pedido as d
on  p.codigo_producto = d.codigo_producto
and d.cantidad < 200
join pedido as ped
on d.codigo_pedido = ped.codigo_pedido
and month(ped.fecha_pedido) = 03

--punto 5
select t.razon_social
from (
		select c.razon_social, sum(v.precio) as "Importe_Total"
		from cliente as c
		join pedido as ped
		on c.codigo_cliente = ped.codigo_cliente
		join detalle_pedido as d
		on ped.codigo_pedido = d.codigo_pedido
		join precio_venta as v
		on d.codigo_producto = v.codigo_producto
		and c.codigo_lista =  v.codigo_lista
		group by razon_social
)as t
where t.importe_total > 850

--punto 6
--yo
select f.razon_social
from fabricante as f
where f.codigo_fabricante not in (select codigo_fabricante 
	from producto as prod
	join detalle_pedido as d
	on prod.codigo_producto = d.codigo_producto
	join pedido as ped
	on d.codigo_pedido = ped.codigo_pedido
	and month(ped.fecha_pedido) = 04 
	where codigo_fabricante = f.codigo_fabricante
	)

--liserre
select razon_social from fabricante
	where codigo_fabricante not in ( select codigo_fabricante from producto 
		where codigo_producto in (select codigo_producto from detalle_pedido 
			where codigo_pedido in (select codigo_pedido from pedido 
				where month(fecha_pedido) = 4)))


--punto 7
select distinct f.razon_social
from fabricante as f
join producto as prod
on f.codigo_fabricante = prod.codigo_fabricante
join detalle_pedido as d
on prod.codigo_producto = d.codigo_producto
join pedido as ped
on d.codigo_pedido = ped.codigo_pedido
and month(ped.fecha_pedido) = 04

--punto 8
select prod.descripcion as "Productos"
from producto as prod
join detalle_pedido as d
on prod.codigo_producto = d.codigo_producto
and d.cantidad > 70
join pedido as ped
on d.codigo_pedido = ped.codigo_pedido
and month(ped.fecha_pedido) = 03

--punto 9
select producto from
(
	select prod.descripcion as "producto", count(prod.descripcion) as "Count"
	from producto as prod
	join precio_venta as v
	on prod.codigo_producto = v.codigo_producto
	join lista as l
	on v.codigo_lista = l.codigo_lista
	group by prod.descripcion
)as t
where count = 1

--punto 10
--Adrianita no tiene clientes, asi que probe con Tony
select t.razon_social
from empleado as e
join pedido as ped
on e.codigo_empleado = ped.codigo_empleado
join(
		select c.codigo_cliente, c.razon_social, sum(v.precio) as "Importe_Total"
		from cliente as c
		join pedido as ped
		on c.codigo_cliente = ped.codigo_cliente
		join detalle_pedido as d
		on ped.codigo_pedido = d.codigo_pedido
		join precio_venta as v
		on d.codigo_producto = v.codigo_producto
		and c.codigo_lista =  v.codigo_lista
		group by c.codigo_cliente,c.razon_social
) as t
on ped.codigo_cliente = t.codigo_cliente
and t.Importe_Total <= 1000
where e.apellido = 'Viguer'
and e.nombre = 'Antonio'

----------------------------------------------------- TP 4 ----------------------------------------------
-- COMANDOS DML ---
--punto 1
create view stockPorFabricante as 
select distinct f.razon_social, p.descripcion, s.cantidad
from fabricante as f
join producto as p
on f.codigo_fabricante = p.codigo_fabricante
join stock as s
on p.codigo_producto = s.codigo_producto;

select * from stockPorFabricante

--punto 2
-- Listar mediante el uso de cursores, para cada oficina nombre de la oficina, 
-- apellido y nombre del director y apellido y nombre de cada uno de los empleados asignados a la oficina.

-- inicio --
-- declaro variables --
declare @oficina as char(50)
declare @cod_oficina as int
declare @cod_director as int
declare @nom_director as char(50)
declare @ape_director as char(50)
-- declaro cursor --
declare cursor_oficina cursor for
select o.descripcion, o.codigo_oficina, e.nombre, e.apellido, o.codigo_director 
from oficina o
left join empleado e
on o.codigo_director = e.codigo_empleado
-- variables cursor empleados --
declare @nom_empleado as char (50)
declare @ape_empleado as char (50)
declare @cod_empleado as int 
-- uso cursor --
open cursor_oficina
fetch next from cursor_oficina into @oficina, @cod_oficina, @nom_director, @ape_director , @cod_director 
while @@FETCH_STATUS = 0
	begin
		print char(13)+'Oficina: '+@oficina;
		print 'Director: ' + rtrim(ltrim(@nom_director)) + ',' + rtrim(ltrim(@ape_director));
		print 'Empleados: ';
		-- declaro cursor para empleados --
		declare cursor_empleados cursor for select distinct e.nombre, e.apellido, e.codigo_empleado
			from empleado e, oficina o where e.codigo_oficina = o.codigo_oficina
		-- uso cursor --
		open cursor_empleados 
		fetch next from cursor_empleados into @nom_empleado, @ape_empleado, @cod_empleado
		while @@FETCH_STATUS = 0
			begin
				if @cod_director <> @cod_empleado or @cod_director is null
					begin
						print rtrim(ltrim(@nom_empleado)) +','+ rtrim(ltrim(@ape_empleado))
					end
				fetch next from cursor_empleados into @nom_empleado, @ape_empleado, @cod_empleado
			end
			close cursor_empleados
			deallocate cursor_empleados
			fetch next from cursor_oficina into @oficina, @cod_oficina, @nom_director, @ape_director, @cod_director
		end
	close cursor_oficina
deallocate cursor_oficina
-- fin --

-- punto 3
--Listar mediante el uso de cursores, de cada pedido los datos del encabezado y su detalle valorizado.
-- variables pedido
declare @cod_pedido int
declare @cod_empleado int 
declare @cod_cliente int
declare @cod_producto int 
declare @cantidad int
-- declaro cursor
declare cursor_pedido cursor for select p.codigo_pedido, p.codigo_empleado, p.codigo_cliente from pedido p
open cursor_pedido
fetch next from cursor_pedido into @cod_pedido, @cod_empleado, @cod_cliente
	while @@FETCH_STATUS = 0
		begin
			print '------------------------------------------------------'
			print 'Codigo de pedido: ' + rtrim(ltrim(@cod_pedido))
			print 'Codigo de empleado: ' + rtrim(ltrim(@cod_empleado))
			print 'Codigo de cliente: ' + rtrim(ltrim(@cod_cliente))
			declare cursor_detalle cursor for select d.codigo_producto, d.cantidad from detalle_pedido d where d.codigo_pedido = @cod_pedido
			open cursor_detalle
			fetch next from cursor_detalle into @cod_producto, @cantidad
				while @@FETCH_STATUS = 0
					begin
						print 'Codigo de producto: ' + rtrim(ltrim(@cod_producto))
						print 'Cantidad: ' + rtrim(ltrim(@cantidad))
						fetch next from cursor_detalle into @cod_producto, @cantidad
					end
					close cursor_detalle
					deallocate cursor_detalle
			fetch next from cursor_pedido into @cod_pedido, @cod_empleado, @cod_cliente
		end
close cursor_pedido
deallocate cursor_pedido

--punto 4
-- Modificar la tabla cliente incorporando el campo "clave" 
-- utilice cursores para completarlo con el nombre de usuario.
declare @cod_cli int
declare @razon_social char(30)
declare @clave char(30)
declare CambioClave cursor for select codigo_cliente, razon_social from cliente
open CambioClave
fetch next from CambioClave into @cod_cli, @razon_social
	while @@FETCH_STATUS = 0
		begin
			set @clave = @razon_social
			update cliente set clave = @clave where codigo_cliente = @cod_cli
			fetch next from CambioClave into @cod_cli, @razon_social
		end
		close CambioClave
		deallocate CambioClave

-- punto 5
-- Crear un procedimiento almacenado que actualice los precios de venta 
-- de todos aquellos productos cuyo precio de venta es menor al precio de venta promedio. 
-- Ingresar por parámetro la lista a actualizar (mayorista o minorista) y el porcentaje de incremento.
create procedure update_precios
	(@tipo_cliente char(20),
	 @porcentaje_incremento int)
	as
Begin transaction
	update precio_venta_aux set precio = precio + precio * @porcentaje_incremento / 100 where precio < (select avg(p.precio) from precio_venta p, lista l where p.codigo_lista = l.codigo_lista and l.descripcion = @tipo_cliente)
	
	if @@ERROR <> 0
		begin
			rollback transaction
			print 'No se pudo agregar el producto'
			return
		end
	commit transaction
return

exec update_precios	
	@tipo_cliente = 'Mayorista',
	@porcentaje_incremento = 10

drop procedure update_precios

--punto 6
-- Crear un procedimiento almacenado que devuelva los datos de todos los productos 
-- o de aquel producto cuya descripción se ingresa por parámetro.
create procedure productos_datos
	(@descripcion char(30) = null)
	as
		if(@descripcion is null)
			select * from producto 
		else
			select * from producto where descripcion = @descripcion
	return

exec productos_datos
	@descripcion = 'Arandela'

drop procedure productos_datos

-- punto7
-- Crear un procedimiento almacenado que permita ingresar nuevos productos en la tabla productos 
-- ingresando los datos del producto por parámetros.
create procedure insert_productos
	(	@descripcion char(30),
		@precio_costo money,
		@codigo_fabricante int
	)
	as
	Begin transaction
		insert into producto (descripcion, precio_costo, codigo_fabricante) values (@descripcion, @precio_costo, @codigo_fabricante) 
		if @@ERROR <> 0
			begin
				print 'No se pudo realizar la insercion del producto'
				rollback
			end
		commit transaction
	return

exec insert_productos
	@descripcion = 'Motosierra asesina',
	@precio_costo = 5000,
	@codigo_fabricante = 1

drop procedure insert_productos

--punto 8
--Crear un procedimiento almacenado que informe de cada fabricante 
-- o del fabricante cuya razón social se ingresa como parámetro, 
-- los productos cuya cantidad en stock es menor al punto de reposición, 
-- indicando cantidad a reponer, costo por producto y costo total por fabricante(no idea).
create procedure informar_stock
	( @razon_social char(30) = null )
	as
		if (@razon_social is null)
			begin
				declare @fabricante char(50)
				declare @fabricante_total money
				declare cursor_fabricantes cursor for select razon_social from fabricante
				open cursor_fabricantes
					fetch next from cursor_fabricantes into @fabricante
						while @@FETCH_STATUS = 0
							begin
								print '----------------------------------------------------------'
								print 'Fabricante: ' + rtrim(ltrim(@fabricante))  
								print 'Listado de productos: ' 
								declare @producto char(30)
								declare @cantidad_reponer int
								declare @costo_producto money
								declare @costo_reposicion money
								declare cursor_productos cursor for select t.descripcion, t.cantidad_reponer, t.precio_costo from (select p.descripcion, s.cantidad, s.pto_reposicion, (s.pto_reposicion - s.cantidad) cantidad_Reponer, p.precio_costo 
										from fabricante f, producto p, stock s where f.razon_social = @fabricante and f.codigo_fabricante = p.codigo_fabricante and p.codigo_producto = s.codigo_producto and s.cantidad < s.pto_reposicion)as t	
								open cursor_productos
								fetch next from cursor_productos into @producto, @cantidad_reponer, @costo_producto
									while @@FETCH_STATUS = 0
										begin
											print '		- '+ rtrim(ltrim(@producto)) + '	Cantidad a reponer: ' + rtrim(ltrim(@cantidad_reponer)) + '		Costo por producto: ' + rtrim(ltrim(@costo_producto))
											fetch next from cursor_productos into @producto, @cantidad_reponer, @costo_producto
										end	
										close cursor_productos
										deallocate cursor_productos
										declare @totales money
										declare cursor_totales cursor for select sum(w.cantidad_Reponer * w.precio_costo) fabricante_total from (select f.razon_social, s.cantidad, s.pto_reposicion, (s.pto_reposicion - s.cantidad) cantidad_Reponer, p.precio_costo from fabricante f, producto p, stock s where f.razon_social = @fabricante and f.codigo_fabricante = p.codigo_fabricante and p.codigo_producto = s.codigo_producto and s.cantidad < s.pto_reposicion)as w
										open cursor_totales
										fetch next from cursor_totales into @totales
										while @@FETCH_STATUS = 0
											begin
												print 'Costo total del fabricante: ' + rtrim(ltrim(@totales))  
												fetch next from cursor_totales into @totales
											end
										close cursor_totales
										deallocate cursor_totales
										fetch next from cursor_fabricantes into @fabricante
									end
				close cursor_fabricantes
				deallocate cursor_fabricantes
			end
		else

			declare @producto1 char(30)
			declare @cantidad_reponer1 int
			declare @costo_prod1 money
			declare @costo_rep1 money
			declare @repTotal money
			declare cursor_fabricante1 cursor for select p.descripcion, (s.pto_reposicion -s.cantidad) as 'Faltante', p.precio_costo as 'Costo', (s.pto_reposicion -s.cantidad)* p.precio_costo as 'Total'  
															from producto p, stock s, fabricante f 
															where s.codigo_producto = p.codigo_producto and p.codigo_fabricante = f.codigo_fabricante 
															and s.cantidad < s.pto_reposicion and f.razon_social = @razon_social
			open cursor_fabricante1
				fetch next from cursor_fabricante1 into @producto1, @cantidad_reponer1, @costo_prod1, @costo_rep1
					while @@FETCH_STATUS = 0
						begin
							print 'Fabricante: ' + rtrim(ltrim(@razon_social))  
							print 'Listado de productos: ' 
							print '		- '+ rtrim(ltrim(@producto1)) + '	Cantidad a reponer: ' + rtrim(ltrim(@cantidad_reponer1)) + '		Costo por producto: ' + rtrim(ltrim(@costo_prod1))
							fetch next from cursor_fabricante1 into @producto1, @cantidad_reponer1, @costo_prod1, @costo_rep1
						end
						set @costo_rep1 = (select sum( @costo_rep1))
						print 'Costo total: ' +rtrim(ltrim(@costo_rep1))					
						close cursor_fabricante1
						deallocate cursor_fabricante1
return

drop procedure informar_stock
exec informar_stock  @razon_social = 'General de Negocios S.A.'

-- punto 9
-- Crear un procedimiento almacenado que ingresando como parámetros: 
-- nombre del producto, cantidad comprada, código de fabricante y precio de costo, 
--realice las siguientes acciones: En el caso en que el producto sea nuevo darlo de alta en la tabla “producto”, 
--en cualquier caso, actualice el stock y el punto de reposición del producto.
create procedure productoInsert_Update
	(
		@nombreProd char(50),
		@cantidadComprada int,
		@cod_fabricante int,			
		@precio_costo money
	)
	as
	declare @codigo_prod int
	if(@nombreProd not in (select descripcion from producto))
		Begin
			Begin transaction
				insert into producto (descripcion, precio_costo, codigo_fabricante) values (@nombreProd, @precio_costo, @cod_fabricante)
				set @codigo_prod = (select codigo_producto from producto where descripcion= @nombreProd)
				insert into stock (codigo_producto, cantidad, pto_reposicion) values  (@codigo_prod, @cantidadComprada, @cantidadComprada)
	
				if @@ERROR <> 0
					begin
						rollback transaction
						print 'No se pudo agregar el producto'
						return
					end
				commit transaction
		End
	else
		Begin
			Begin transaction
				set @codigo_prod = (select codigo_producto from producto where descripcion= @nombreProd)
				update stock set cantidad = cantidad + @cantidadComprada, pto_reposicion = pto_reposicion + @cantidadComprada where codigo_producto = @codigo_prod
				
				if @@ERROR <> 0
					begin
						rollback transaction
						print 'No se pudo actualizar el producto'
						return
					end
				commit transaction
		End
return

drop procedure productoInsert_Update

exec productoInsert_Update
		@nombreProd = 'Cuchilla destripadora',
		@cantidadComprada = 100,
		@cod_fabricante	= 2,	
		@precio_costo = 3500

		select * from producto
		select * from stock

--punto 10
--Crear un desencadenador (trigger) en la tabla “producto” que, ante el ingreso de un nuevo producto, 
--incorpore en la tabla “precio_venta” los precios de venta mayorista y minorista 
--considerando los porcentajes de ganancia indicados en la tabla “lista”
create trigger precioVenta on producto for insert
as
declare @codigo_lista int
declare @porcentaje int
declare cursor_lista cursor for select codigo_lista, ganancia_porcentaje from lista
open cursor_lista 
fetch cursor_lista into @codigo_lista, @porcentaje
while @@FETCH_STATUS = 0
	begin
		insert into precio_venta (codigo_producto, codigo_lista, precio) 
			select codigo_producto, @codigo_lista, (precio_costo +  precio_costo * @porcentaje / 100) from inserted 
				fetch cursor_lista into @codigo_lista, @porcentaje
	end
	deallocate cursor_lista

-- punto 11
-- Crear un desencadenador (trigger) que grabe en la tabla auditoría_producto (la que deberá crear), 
--los valores anteriores cuando se actualiza un producto.
create table auditoria_producto
( codigo_producto int , 
  descripcion varchar(50), 
  precio_costo money , 
  codigo_fabricante int,
  fecha_actualizacion datetime);

create trigger auditar on producto for update
as
insert into auditoria_producto(codigo_producto, descripcion, precio_costo, codigo_fabricante, 
			fecha_actualizacion) select del.codigo_producto, del.descripcion, del.precio_costo,
			del.codigo_fabricante, getdate() FROM deleted del

select * from producto
select * from auditoria_producto

update producto set precio_costo = 5 where codigo_producto = 1001

drop trigger auditar

--punto 12
-- Crear un desencadenador (trigger) en la tabla "detalle_pedido" para la acción de inserción 
-- que controle si la cantidad que se intenta pedir sea menor o igual al stock del producto. 
--En el caso en que la cantidad pedida sea menor o igual al stock, debe permitir el insert y actualizar el stock del producto.
-- En el caso en que el stock no sea suficiente, debe informar que no es posible la operación y abortarla.
create trigger stock_control on detalle_pedido for insert
as
declare @stock int
set @stock = (select s.cantidad from stock s, inserted i where s.codigo_producto = i.codigo_producto)
declare @pedido int
set @pedido = (select cantidad from inserted)
if(@stock >= (select cantidad from inserted))
	begin
		update stock set cantidad = cantidad - @pedido
	end
else
	begin
		raiserror ('Hay menos productos en sotck de los solicitados pra el pedido', 16,1)
		rollback transaction
	end

--- punto 13
-- Activar o desactivar desencadenadores.
alter table detalle_pedido disable trigger stock_control
alter table detalle_pedido enable trigger stock_control

---------------------------------------------------- TP 5 ------------------------------------------------------------------------
--punto 1 --
--Incorpore en la tabla “articulo”, la columna “precio_venta” como columna calculada. 
--El valor de la columna “precio_venta” surge de incrementar en un 5% el “precio”.
alter table articulo add precio_venta as (precio + precio * 5 /100)

--punto 2
-- Verifique la estructura utilizando el procedimiento almacenado sp_help.
sp_help articulo

--punto 4
--Cree un procedimiento almacenado, que incremente la columna “precio” en un porcentaje fijo.
create procedure incrementar_precio (@porcentaje int)
as
begin transaction 
	update articulo set precio = precio + precio * @porcentaje / 100

	if @@ERROR <> 0
		begin
			rollback transaction
			print 'No se pudo actualizar precio'
			return
		end
	commit transaction
return 

exec incrementar_precio 
	@porcentaje = 10

drop procedure incrementar_precio

--punto 5
-- Cree la tabla “parámetros” con la siguiente estructura:
-- id_parametro identity(1,1)
-- descripcion varchar(50)
-- valor int

create table parametros
(	
	id_parametro int primary key identity (1,1),
	descripcion varchar(50),
	valor int
);

--punto 6
-- Incorpore a la tabla “parámetros”, un registro con los siguientes datos: valor = 5, descripción = 'Porcentaje de ganancia’
insert into parametros (valor, descripcion) values (5, 'Porcentaje de ganancia')

--punto 7
--Cree un procedimiento almacenado, que actualice el precio de venta de la tabla “artículos”, 
--en el porcentaje indicado en la tabla parametros como 'Porcentaje de ganancia’.
create procedure actualizar_prevArt 
as
	update articulo set precio_venta = precio_venta + precio_venta * (select valor from parametros where descripcion = 'Porcentaje de ganancia') / 100
return
--punto 9
--Agregue en la tabla Cliente una columna denominada limite_credito - tipo Money 
--con una restricción check que garantice que su valor no pueda ser mayor o igual a $35.000.

	alter table cliente add limite_credito money not null default 0
	alter table cliente add constraint C_limite check (limite_credito < 35000) 
	
--punto 12
-- Cree un procedimiento almacenado, que actualice el campo limite_credito de la tabla “cliente”, a un valor inicial ($10.000), ingresado como parámetro
create procedure update_limiteCred
	(@valor money)
as
	begin transaction
		update cliente set limite_credito = @valor
		if @@ERROR <> 0
			begin
				rollback transaction
				print 'No se pudo actualizar el valor del limite_credito'
				return
			end
		commit transaction
return

exec update_limiteCred
	@valor = 10000

--punto 13
-- Cree un procedimiento almacenado, que permita, incorporar nuevos artículos en la tabla “articulo”. 
--Los valores correspondientes a las columnas: “descripción”, “tipo_articulo” y “precio”, por parámetro. Utilice transacciones.
create procedure incorporar_articulos
(
	@descripcion char(50), 
	@tipo_articulo char(1),
	@precio money
)
as
begin transaction
	insert into articulo (descripcion, tipo_articulo, precio) values (@descripcion, @tipo_articulo, @precio)
	if @@ERROR <> 0
		begin
			rollback transaction
			print 'No se pudo ingresar el articulo'
			return
		end
	commit transaction
return

exec incorporar_articulos
	@descripcion = 'motosierra',
	@tipo_articulo = 'A',
	@precio = 1999


select*  from articulo