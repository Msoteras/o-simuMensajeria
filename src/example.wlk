// PUNTOS DE ENTRADA

/*
 Punto 1 _  chat.espacioOcupado()
 Punto 2 _ chat.recibir(mensaje
 Punto 3 _ usuario.buscarTexto(unTexto)
 Punto 4 _ usuario.mensjaesPesados()
 Punto 5
 Punto 6 
 */
/******Los mensajes*****/
class Mensaje{
	const property emisor
	
	method peso() = 5 + self.pesoContenido() * 1.3
	
	method pesoContenido() // porque el peso de un mensaje es 5 * el peso del contenido por 1.3, por eso lo separo
	
	method contiene(unTexto) = emisor.contieneNombre(unTexto)
}

class DeTexto inherits Mensaje {
	const texto
	
	override method pesoContenido() = texto.size()
	
	override method contiene(unTexto) =
		super(unTexto) || texto.contains(unTexto)
	
}

class Audio inherits Mensaje{
	const duracion
	
	override method pesoContenido() = duracion * 1.2 
}

class Contacto inherits Mensaje{
	const usuario
	
	override method pesoContenido() = 3
	
	override method contiene(unTexto) = super(unTexto) || usuario.contieneNombre(unTexto)
}

class Imagen inherits Mensaje{
	var property alto
	var property ancho
	var property compresion = original
	
	method pixelesAEnviar() = compresion.pixeles(ancho*alto)
	
	override method pesoContenido() = self.pixelesAEnviar() * 2
}

class Gif inherits Imagen{
	const cantCuadros
	
	override method pesoContenido() = super() * cantCuadros
}

// Tipos Compresion
object original{
	method pixeles(pixeles) = pixeles
}

class Variable{
	const porcentaje
	
	method pixeles(pixeles) = pixeles * porcentaje /100
}

object maxima{
	method pixeles(pixeles) = pixeles.min(10000)
}



/****CHATS*****/

class Chat{
	var participantes = []
	var mensajesEnviados= []
	

	method espacioOcupado() = mensajesEnviados.sum{mensaje => mensaje.peso()}
	
	method recibir(mensaje){
		self.validarEnvio(mensaje)
		mensajesEnviados.add(mensaje)
		self.enviarNotificacion(self)
	}
	
	method validarEnvio(mensaje){
		self.validarEmisor(mensaje)
		self.validarAlmacenamiento(mensaje)
	}
	
	method validarEmisor(mensaje){
		if(!self.mensajeDeParticipante(mensaje)){
			throw new DomainException(message = "El emisor no pertenece a este chat")
		}
		
	}
	
	method validarAlmacenamiento(mensaje){
		if(!self.participantesConMemoriaSuficiente(mensaje)){
			throw new DomainException(message = "Los participantes no tienen almacenamiento suficiente")
		}
	}
	
	method enviarNotificacion(chat) {
		participantes.forEach{participante => participante.recibirNotificacion(chat)}
	}
	
	method mensajeDeParticipante(mensaje) = participantes.contains(mensaje.emisor())
	
	method participantesConMemoriaSuficiente(mensaje) = participantes.all{participante => participante.tieneEspacioPara(mensaje)}
	
	method cantidadDeMensajes() = mensajesEnviados.size()
	
	method contieneTexto(unTexto) = mensajesEnviados.any{mensaje => mensaje.contiene(unTexto)}
	
	method mensajeMasPesado() = mensajesEnviados.max{mensaje => mensaje.peso()}
	
	//no se pide
	method agregarParticipante(usuario) {
		participantes.add(usuario)
		usuario.nuevoChat(self)
	}
}

class Premium inherits Chat{
	var restriccion 
	const creador
	
	override method recibir(mensaje){
		super(mensaje) //Si en la super lo añadi, tendria que sacarlo si tira la excepcion?
		restriccion.validarEnvio(mensaje, self)
	}
}

/***** Restricciones *******/

object difusion{
	
	method validarEnvio(mensaje, chat){
		if(chat.creador() != mensaje.emisor()){
			throw new DomainException(message = "Solo el creador del chat puede enviar mensajes")
		}
	}
}

class Restrignido{
	const limite
	
	method validarEnvio(mensaje, chat){
		if(chat.cantidadDeMensajes() >= limite){
			throw new DomainException(message = "Se ha alcanzado el limite de mensajes a enviar")
		}
	}
	
}

class Ahorro{
	const pesoMaximo
	
	method validarEnvio(mensaje, chat){
		if(mensaje.peso() > pesoMaximo){
			throw new DomainException(message = "El mensaje supera el peso maximo")
		}
	}
}

class Usuario{
	var almacenamiento
	var chats = []
	const nombre
	var property notificaciones = []
	
	method tieneEspacioPara(mensaje) = self.espacioLibre() >= mensaje.peso()
	
	method espacioLibre() = almacenamiento - self.espacioOcupadoPorChats()
	
	method espacioOcupadoPorChats() = chats.sum{chat => chat.espacioOcupado()}
	
	method buscarTexto(unTexto) = chats.filter{chat => chat.contieneTexto(unTexto)}
	
	method contieneNombre(unTexto) = nombre.contains(unTexto)
	
	method mensajesPesados() = chats.map{chat => chat.mensajeMasPesado()}
	
	method recibirNotificacion(unChat){
		notificaciones.add(new Notificacion(chat = unChat))
	} 
	
	method leerUnChat(unChat){
		self.notificacionesDelChat(unChat).forEach{notificacion => notificacion.leer()}
	}
	
	method notificacionesDelChat(unChat) = notificaciones.filter{notificacion => notificacion.esDelChat(unChat)}
	
	method notificacionesSinLeer() = notificaciones.filter{notificacion => !notificacion.estaLeida()}
	
	// no se pide
	method nuevoChat(unChat){
		chats.add(unChat)
	}
}

class Notificacion{
	const chat
	var property estaLeida = false
	
	method leer() {
		estaLeida = true
	}
	
	method esDelChat(unChat) = unChat == chat
}

