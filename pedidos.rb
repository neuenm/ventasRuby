require 'rubygems'
require 'sinatra'
require 'slim'
require 'data_mapper'
# Inicializacion, declarando tipo y path de la base de datos
DataMapper.setup(:default, 'sqlite:db/development.db')

# Habilita un log en la consola que tenga el server corriendo de lo
# que se hace en la base de datos
DataMapper::Logger.new($stdout, :debug)
	
class Venta
	include DataMapper::Resource
	property :id ,Serial
    property :fecha , Date
    property :total, Integer
    property :cliente, String
    has n, :productos , :through => Resource
end

class Producto
	include DataMapper::Resource
	property :id ,Serial
	property :nombre, String
	property :precio , String
	property :cantidad, Integer
	property :categoria, String
	has n, :ventas , :through => Resource
end


class Cliente
	include DataMapper::Resource
	property :id, Serial
	property :nombre, String
	property :local, String
	property :direccion, String
end



Cliente.auto_upgrade!
Venta.auto_upgrade!
Producto.auto_upgrade!
/DataMapper.auto_migrate!/
/DataMapper.auto_upgrade!/

get "/" do 
	slim :layout
end

get "/nuevo" do
	p "Producto.all.length"
	p Producto.count
	@Productos= Producto.all();
	@Clientes = Cliente.all();
	slim :ventaNueva;
end


post "/nuevo" do
	i=0
	j=params[:nombre].length
	venta = Venta.new(:cliente=>params[:cliente], :fecha=>DateTime.now.to_date, :total=>params[:total])
	while i<j
		producto = Producto.first(:nombre=>params[:nombre][i])
		producto.cantidad = params[:cantidad][i]
		venta.productos << producto
		i += 1
	end
	if venta.save
		redirect "/listado"
	else
		p algo salio mal
	end
end




get "/verhoy" do
	@listado=Venta.all(:fecha=>DateTime.now.to_date)
	slim :listado
end

post "/fecha" do
	@fecha=params["fecha"]
	@listado=Venta.all(:fecha=>@fecha)
	@clientes=Cliente.all()
	slim  :listado
end


post "/cliente" do
	@cliente=params["cliente"]
	@clientes= Cliente.all();
	@listado=Venta.all(:cliente=>@cliente)
	slim  :listado
end

get "/listado" do
	@listado=Venta.all()
	@clientes=Cliente.all()
	slim :listado
end

get "/detalle/:id" do
	@detalle=Venta.get(params['id'])
	@productos= @detalle.productos
	@total=@detalle.total
	p @total
	p @productos
	slim :detalle
end




get "/listado/productos" do 
	@productos= Producto.all();
	slim :listadoProductos	
end

get "/producto/nuevo" do 
	slim :nuevoPorducto
end


post "/producto/nuevo" do 
	producto = Producto.first_or_create({:nombre=>params[:nombre]}, {:precio=>params[:precio], :cantidad=>0, :categoria=>params[:categoria]});
	if producto.save
		redirect "/listado/productos"
	else
		p alfo salio0 mal
	end
end



get "/producto/editar/:id" do
	@producto=Producto.get(params['id'])
	slim :editaProducto
end

post "/producto/editar/:id" do
	@producto=Producto.get(params["id"])
	@producto.update(:nombre=>params[:nombre], :precio=>params[:precio], :cantidad=>0, :categoria=>params[:categoria]);
	@productos= Producto.all();
	slim :listadoProductos
end



get "/cliente/editar/:id" do
	@cliente=Cliente.get(params["id"])
	slim :editaCliente
end

post "/cliente/editar/:id" do
	@cliente=Cliente.get(params["id"])
	@cliente.update(:nombre=>params[:nombre], :local=>params[:local],:direccion=>params[:direccion]);
	@clientes=Cliente.all();
	slim :listadoClientes
end
get "/producto/eliminar/:id" do
	@producto=Producto.get(params["id"])
	@producto.destroy
	@productos= Producto.all();
	slim :listadoProductos	
end


get "/cliente/eliminar/:id" do
	@cliente=Cliente.get(params["id"])
	@cliente.destroy
	@clientes= Cliente.all();
	slim :listadoClientes	
end


get "/nuevo/cliente" do
	slim :nuevoCliente
end


post "/nuevo/cliente" do
	cliente = Cliente.new(:nombre=>params[:nombre], :local=>params[:local],:direccion=>params[:direccion]);
	if cliente.save
		redirect "/listado/clientes"
	else
		p "alfo salio mal"
	end
end

get "/listado/clientes" do
	@clientes= Cliente.all();
	slim :listadoClientes
end