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
    property :cliente,  String
    property :fecha , Date
    property :total, Integer

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
Venta.auto_upgrade!
Producto.auto_upgrade!

/DataMapper.auto_migrate!/
/DataMapper.auto_upgrade!/

get "/" do 
	slim :layout
end

get "/nuevo" do
	@Productos= Producto.all();
	slim :ventaNueva
end


post "/nuevo" do
	i=0
	j=params[:nombre].length
	venta = Venta.new(:cliente=>params[:cliente], :fecha=>DateTime.now.to_date, :total=>params[:total])
	while i<j
		producto = Producto.new(:nombre=>params[:nombre][i], :precio=>params[:precio][i], :cantidad=>params[:cantidad][i], :categoria=>params[:categoria])
		venta.productos << producto
		i += 1
	end

	p venta.productos[0].nombre
	p venta

	if venta.save
		redirect "/listado"
	else
		p alfo salio0 mal
	end
end













get "/verhoy" do
	@listado=Venta.all(:fecha=>DateTime.now.to_date)
	slim :listado
end

post "/fecha" do
	@fecha=params["fecha"]
	@listado=Venta.all(:fecha=>@fecha)
	slim  :listado
end


post "/cliente" do
	@cliente=params["cliente"]
	@listado=Venta.all(:cliente=>@cliente)
	slim  :listado
end

get "/listado" do
	@listado=Venta.all()
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
	producto = Producto.new(:nombre=>params[:nombre], :precio=>params[:precio], :cantidad=>0, :categoria=>params[:categoria]);
	if producto.save
		redirect "/listado/productos"
	else
		p alfo salio0 mal
	end
end




get "/producto/editar/:id" do
	@producto=Producto.get(params["id"])
	slim :editaProducto
end


get "/producto/eliminar/:id" do
	@producto=Producto.get(params["id"])
	@producto.destroy
	@productos= Producto.all();
	slim :listadoProductos	
end