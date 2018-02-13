#require 'nokogiri'

class DataFile < ActiveRecord::Base
  
  @path
  
  def initialize(strtrama)
   @strtrama = strtrama
   @path = ""
  end
  

  def save(upload)
      name = upload['datafile'].original_filename
      directory = '/tmp'
      @path = File.join(directory, name)
      File.open(@path,"w+b") { |f| f.write(upload['datafile'].read) }
      
      #  tramaoriginal(path)
  end

  def rutafile()
      return @path
  end

  def tramaoriginal(xmlfiles,tipocpe)


    xml = File.new(xmlfiles)

    xml_doc = Nokogiri::XML(xml)

    # Awesome this works!

    cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
    cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
    sac="urn:sunat:names:specification:ubl:peru:schema:xsd:SunatAggregateComponents-1"
    xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
    strparentname = ""
    idline = 1

    colum = "|"
    
    if tipocpe == "01" || tipocpe == "03"
       strcpe = "//cac:InvoiceLine"
       strquantity = "cbc:InvoicedQuantity"
       parentline = "InvoiceLine"    
       strroot = "Invoice" 
    else 
       strcpe = "//cac:CreditNoteLine"
       strquantity = "cbc:CreditedQuantity"
       parentline = "CreditNoteLine" 
       strroot = "CreditNote"
    end
 
   #Encabezado
    strtrama =  "<b>EN|</b>" + tipocpe.to_s + "|"   #Tipo de Documento
   #Serie y Correlativo  
   xml_doc.xpath('//cbc:ID','cbc' => cbc).each do |element|
           if element.parent.name ==strroot 
               strtrama = strtrama + element.text + "|" 
           end
    end

    strtrama = strtrama +
    xml_doc.xpath('//cac:DiscrepancyResponse/cbc:ResponseCode', 'cac' => cac, 'cbc' => cbc).text + colum +  #Tipo de Nota de Credito Debito
    xml_doc.xpath('//cac:DiscrepancyResponse/cbc:ReferenceID', 'cac' => cac, 'cbc' => cbc).text + colum +  #Factura que Referencia a la NC
    xml_doc.xpath('//cac:DiscrepancyResponse/cbc:Description', 'cac' => cac, 'cbc' => cbc).text + colum   # Sustento

    #Fecha de Emision
     xml_doc.xpath('//cbc:IssueDate','cbc' => cbc).each do |element|
           if element.parent.name ==strroot 
               strtrama = strtrama + element.text + "|" 
           end
    end
   # xml_doc.xpath('//cbc:IssueDate' , 'cbc' => cbc).text + colum +  #Fecha de Emision

    strtrama = strtrama +
    xml_doc.xpath('//cbc:DocumentCurrencyCode' , 'cbc' => cbc).text + colum + # Tipo de Moneda
    xml_doc.xpath('//cac:AccountingSupplierParty/cbc:CustomerAssignedAccountID' ,'cac' => cac, 'cbc' => cbc).text + colum + # RUC Emisor
    xml_doc.xpath('//cac:AccountingSupplierParty/cbc:AdditionalAccountID' , 'cac' => cac, 'cbc' => cbc).text + colum + # Identificador Emisor
                # Nombre comercial del Emisor
    xml_doc.xpath('//cac:AccountingSupplierParty/cac:Party/cac:PartyName/cbc:Name' , 'cac' => cac, 'cbc' => cbc).text + colum + 

    xml_doc.xpath('//cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName' , 'cac' => cac, 'cbc' => cbc).text + colum + # Razon Social Emisor
    xml_doc.xpath('//cac:PostalAddress/cbc:ID' , 'cac' => cac, 'cbc' => cbc).text + colum + # Codigo Ubigeo del Emisor

    xml_doc.xpath('//cac:PostalAddress/cbc:StreetName' , 'cac' => cac, 'cbc' => cbc).text + colum + # Direccion del Emisor
    xml_doc.xpath('//cac:PostalAddress/cbc:CountrySubentity' , 'cac' => cac, 'cbc' => cbc).text + colum + # Departamento del Emisor
    xml_doc.xpath('//cac:PostalAddress/cbc:CityName' , 'cac' => cac, 'cbc' => cbc).text + colum + # Provincia del Emisor
    xml_doc.xpath('//cac:PostalAddress/cbc:District' , 'cac' => cac, 'cbc' => cbc).text + colum + # Distrito del Emisor
    xml_doc.xpath('//cac:AccountingCustomerParty/cbc:CustomerAssignedAccountID' , 'cac' => cac, 'cbc' => cbc).text + colum + # Ruc del Receptor
    xml_doc.xpath('//cac:AccountingCustomerParty/cbc:AdditionalAccountID' , 'cac' => cac, 'cbc' => cbc).text + colum + #Identificador Receptor
    xml_doc.xpath('//cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName' , 'cac' => cac, 'cbc' => cbc).text + colum + # Razon Social Receptor
    xml_doc.xpath('//cac:RegistrationAddress/cbc:StreetName' , 'cac' => cac, 'cbc' => cbc).text + colum + # Direccion del Receptor
    xml_doc.xpath('//cac:LegalMonetaryTotal/cbc:LineExtensionAmount' , 'cac' => cac, 'cbc' => cbc).text + colum + # Monto Neto
    xml_doc.xpath('//cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount' , 'cac' => cac, 'cbc' => cbc).text + colum + # Monto Impuestos
    xml_doc.xpath('//cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount' , 'cac' => cac, 'cbc' => cbc).text + colum + # Monto Descuentos
    xml_doc.xpath('//cac:LegalMonetaryTotal/cbc:ChargeTotalAmount' , 'cac' => cac, 'cbc' => cbc).text + colum +  #Monto Recargos
    xml_doc.xpath('//cac:LegalMonetaryTotal/cbc:PayableAmount' , 'cac' => cac, 'cbc' => cbc).text + colum + #Monto Total
    ""+colum + # /codigos de otros conceptos tributarios recomendados
    ""+colum + # Total de Valor Venta Neto
     # numero de documento de identidad del adquirente o usuario  
    xml_doc.xpath('//cac:AccountingCustomerParty/cbc:CustomerAssignedAccountID' , 'cac' => cac, 'cbc' => cbc).text + colum + 
    # Tipo de documento de identidad del adquirente o usuario
    xml_doc.xpath('//cac:AccountingCustomerParty/cbc:AdditionalAccountID' , 'cac' => cac, 'cbc' => cbc).text + colum +  
    xml_doc.xpath('//cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode' , 'cac' => cac, 'cbc' => cbc).text + colum +  # Codigo del pais emisor
    xml_doc.xpath('//cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:CitySubdivisionName' , 'cac' => cac, 'cbc' => cbc).text + colum +   # Urbanización Emisor

xml_doc.xpath('//sac:AdditionalInformation/sac:SUNATEmbededDespatchAdvice/cac:OriginAddress/cbc:ID' , 'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum + #Dirección del Punto de Partida, Código de Ubigeo


xml_doc.xpath('//sac:AdditionalInformation/sac:SUNATEmbededDespatchAdvice/cac:OriginAddress/cbc:StreetName' , 'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum  +      #Dirección del Punto de Partida, Dirección completa y detallada
   
xml_doc.xpath('//sac:AdditionalInformation/sac:SUNATEmbededDespatchAdvice/cac:OriginAddress/cbc:CitySubdivisionName' , 'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum  + #Dirección del Punto de Partida, Urbanización

xml_doc.xpath('//sac:AdditionalInformation/sac:SUNATEmbededDespatchAdvice/cac:OriginAddress/cbc:CityName' , 'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum + #Dirección del Punto de Partida, Provincia

xml_doc.xpath('//sac:AdditionalInformation/sac:SUNATEmbededDespatchAdvice/cac:OriginAddress/cbc:CountrySubentity' , 'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum + #Dirección del Punto de Partida, Departamento

xml_doc.xpath('//sac:AdditionalInformation/sac:SUNATEmbededDespatchAdvice/cac:OriginAddress/cbc:District' , 'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum + #Dirección del Punto de Partida, Distrito


xml_doc.xpath('//sac:AdditionalInformation/sac:SUNATEmbededDespatchAdvice/cac:OriginAddress/cac:Country/cbc:IdentificationCode' , 'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum + #Dirección del Punto de Partida, Código de País

xml_doc.xpath('//sac:AdditionalInformation/sac:SUNATEmbededDespatchAdvice/cac:DeliveryAddress/cbc:ID' , 'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum + #Dirección del Punto de Llegada, Código de Ubigeo


xml_doc.xpath('//sac:AdditionalInformation/sac:SUNATEmbededDespatchAdvice/cac:DeliveryAddress/cbc:StreetName' , 'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum + # Dirección del Punto de Llegada, Dirección completa y detallada

xml_doc.xpath('//sac:AdditionalInformation/sac:SUNATEmbededDespatchAdvice/cac:DeliveryAddress/cbc:CitySubdivisionName' , 'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum + # Dirección del Punto de Llegada, Urbanización

xml_doc.xpath('//sac:AdditionalInformation/sac:SUNATEmbededDespatchAdvice/cac:DeliveryAddress/cbc:CityName' , 'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum + # Dirección del Punto de Llegada, Provincia

xml_doc.xpath('//sac:AdditionalInformation/sac:SUNATEmbededDespatchAdvice/cac:DeliveryAddress/cbc:CountrySubentity' , 'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum + # Dirección del Punto de Llegada, Departamento

xml_doc.xpath('//sac:AdditionalInformation/sac:SUNATEmbededDespatchAdvice/cac:DeliveryAddress/cbc:District' , 'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum + # Dirección del Punto de Llegada, Distrito

xml_doc.xpath('//sac:AdditionalInformation/sac:SUNATEmbededDespatchAdvice/cac:DeliveryAddress/cac:Country/cbc:IdentificationCode' , 'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum +  # Dirección del Punto de Llegada, Código de País

xml_doc.xpath('//sac:SUNATEmbededDespatchAdvice/sac:SUNATRoadTransport/cbc:LicensePlateID' , 'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum + # Placa del Vehiculo

xml_doc.xpath('//sac:AdditionalInformation/sac:SUNATEmbededDespatchAdvice/sac:SUNATRoadTransport/cbc:TransportAuthorizationCode' , 'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum + # N° constancia de inscripción del vehículo o certificado de habilitacion vehicular

xml_doc.xpath('//sac:SUNATEmbededDespatchAdvice/sac:SUNATRoadTransport/cbc:BrandName' , 'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum + # Marca Vehículo

xml_doc.xpath('//sac:SUNATEmbededDespatchAdvice/sac:DriverParty/cac:Party/cac:PartyIdentification/cbc:ID' , 'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum + # N° de licencia de conducir

xml_doc.xpath('//sac:SUNATEmbededDespatchAdvice/sac:SUNATCarrierParty/cbc:CustomerAssignedAccountID' , 'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum + # Ruc transportista

xml_doc.xpath('//sac:SUNATEmbededDespatchAdvice/sac:SUNATCarrierParty/cbc:CustomerAssignedAccountID' , 'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum + # Ruc transportista -Tipo Documento

xml_doc.xpath('//sac:SUNATEmbededDespatchAdvice/sac:SUNATCarrierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName' , 'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum + # Razón social del transportista


xml_doc.xpath('//cac:PaymentTerms/cbc:Note' , 'cac' => cac, 'cbc' => cbc).text + colum + # Condiciones de pago

xml_doc.xpath('//cac:OrderReference/cbc:ID' , 'cac' => cac, 'cbc' => cbc).text + colum + # Orden de Compra

xml_doc.xpath('//cac:ContractDocumentReference/cbc:ID' , 'cac' => cac, 'cbc' => cbc).text + colum + # Número de contrato


xml_doc.xpath('//cbc:Note' , 'cac' => cac, 'cbc' => cbc).text + colum + # Nota general del documento


xml_doc.xpath('//cac:Shipment/cbc:InsuranceValueAmount' , 'cac' => cac, 'cbc' => cbc).text + colum + # Valor del seguro

xml_doc.xpath('//cac:Shipment/cac:FreightAllowanceCharge/cbc:Amount' , 'cac' => cac, 'cbc' => cbc).text + colum + # Valor del flete
xml_doc.xpath('//cac:Shipment/cbc:FreeOnBoardValueAmount' , 'cac' => cac, 'cbc' => cbc).text + colum + # Valor FOB
xml_doc.xpath('//cac:LegalMonetaryTotal/cbc:PayableRoundingAmount' , 'cac' => cac, 'cbc' => cbc).text + colum + # Redondeo
xml_doc.xpath('//cbc:SupplierAssignedAccountID' , 'cac' => cac, 'cbc' => cbc).text + colum + # Codigo del Proveedor
xml_doc.xpath('//sac:SUNATTransaction/cbc:ID ' ,'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum + # Tipo de Operación
xml_doc.xpath('///Invoice/cac:LegalMonetaryTotal/cbc:PrepaidAmount 
' , 'cac' => cac, 'cbc' => cbc).text + colum + # Total Anticipos


#Dirección del lugar en el que se entrega el bien o se presta el servicio (Código de ubigeo - Catálogo No. 13)
xml_doc.xpath('//cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:ID' , 'cac' => cac, 'cbc' => cbc).text + colum +

#Dirección del lugar en el que se entrega el bien o se presta el servicio (Dirección completa y detallada)
xml_doc.xpath('//cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName' , 'cac' => cac, 'cbc' => cbc).text + colum +

#Dirección del lugar en el que se entrega el bien o se presta el servicio(Urbanización)
xml_doc.xpath('//cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:CitySubdivisionName' , 'cac' => cac, 'cbc' => cbc).text + colum +

#Dirección del lugar en el que se entrega el bien o se presta el servicio (Provincia)
xml_doc.xpath('//cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:CityName' , 'cac' => cac, 'cbc' => cbc).text + colum +

#Dirección del lugar en el que se entrega el bien o se presta el servicio (Departamento)
xml_doc.xpath('//cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:CountrySubentity' , 'cac' => cac, 'cbc' => cbc).text + colum +

#Dirección del lugar en el que se entrega el bien o se presta el servicio (Distrito)
xml_doc.xpath('//cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:District' , 'cac' => cac, 'cbc' => cbc).text + colum +

#Dirección del lugar en el que se entrega el bien o se presta el servicio (Código de país - Catálogo No. 04)
xml_doc.xpath('//cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode' , 'cac' => cac, 'cbc' => cbc).text + colum +

#Número de placa del vehículo (Información Adicional - Gastos art.37º Renta),  vehiculo que se le brinda el servicio
xml_doc.xpath('//sac:SUNATCosts/cac:RoadTransport/cbc:LicensePlateID' , 'sac' => sac,'cac' => cac, 'cbc' => cbc).text + colum +


#Fecha de Vencimiento de la Factura
xml_doc.xpath('//cbc:ExpiryDate' , 'cac' => cac, 'cbc' => cbc).text + colum +


#Modalidad de Traslado del remitente
xml_doc.xpath('//sac:SUNATEmbededDespatchAdvice/cbc:TransportModeCode' ,'sac' => sac, 'cac' => cac, 'cbc' => cbc).text + colum 

#DETALLE DE OTROS CONCEPTOS DOC
  strtrama = strtrama + "<br>"
  xml_doc.xpath("//sac:AdditionalMonetaryTotal",'sac' => sac ).each do |element|
        # C√≥digos de otros conceptos tributarios o comerciales recomendados    
    strtrama = strtrama +  "<b>DOC|</b>" + (element.xpath('cbc:ID','cbc' => cbc).text).to_s + colum + 
        (element.xpath('cbc:PayableAmount', 'cbc' => cbc).text).to_s + colum + # Total Valor Venta Neto
        (element.xpath('sac:TotalAmount', 'sac' => sac).text).to_s + colum + #Monto Total del documento incluida la percepcion
        #Base Imponible percepcion o Valor Referencial del sercicio de transporte de bienes realizado por via terrestre
        (element.xpath('sac:ReferenceAmount', 'sac' => sac).text).to_s  + colum +
        #Porcentaje de Detraccion 
       (element.xpath('cbc:Percent', 'cbc' => cbc).text).to_s + colum +
        #Regimen de Percepcion 
        element.xpath('cbc:ID','cbc' => cbc).attribute('schemeID').to_s
       
       
         strtrama = strtrama + "<br>"
    end

   #NOTAS DEL DOCUMENTO DN
   contador =1
  
        xml_doc.xpath("//sac:AdditionalProperty",'sac' => sac ).each do |element|
            strtrama = strtrama + "<b>DN|</b>" + contador.to_s + "|" + # Número de Línea de Nota
            element.xpath('cbc:ID','cbc' => cbc).text + "|" + # C0digos de LA LEYENDA
            element.xpath('cbc:Value', 'cbc' => cbc).text + "|" +  # Glosa de la Leyenda
            element.xpath('cbc:Name', 'cbc' => cbc).text  #Descripcion del tramo o viaje
            strtrama = strtrama + "<br>"
            contador += 1   
        end

   #DETALLES DEL ITEM DE
        xml_doc.xpath(strcpe, 'cac' => cac  ).each do |element|
            strtrama = strtrama + "<b>DE|</b>" +
            element.xpath('cbc:ID','cbc' => cbc).text + "|" + # Correlativo de la Linea o Detalle
            # Precio de Venta Unitario x item
            element.xpath('cac:PricingReference/cac:AlternativeConditionPrice/cbc:PriceAmount', 'cac' => cac,'cbc' => cbc).text + "|" + 
            element.xpath( strquantity +'[@unitCode]','cbc' => cbc).attribute('unitCode') + "|"  + # Unidad de medida
            element.xpath(strquantity,'cbc' => cbc).text + "|" + # Cantidad de Unidades Vendidas
            element.xpath('cbc:LineExtensionAmount','cbc' => cbc).text + "|" + # Valor de venta por ITEM
            element.xpath('cac:Item/cac:SellersItemIdentification/cbc:ID', 'cac' => cac,'cbc' => cbc).text + "|" + # Codigo del Item
            # Tipo de precio de venta
            element.xpath('cac:PricingReference/cac:AlternativeConditionPrice/cbc:PriceTypeCode', 'cac' => cac,'cbc' => cbc).text + "|" + 
            element.xpath('cac:Price/cbc:PriceAmount','cac' => cac,'cbc' => cbc).text + "|" + # Valor de venta unitario x item
            element.xpath('cbc:LineExtensionAmount','cac' => cac,'cbc' => cbc).text + "|" + # Valor de venta por ITEM
            # Número de lote   
            element.xpath('cac:Item/cac:ItemInstance/cac:LotIdentification/cbc:LotNumberID','cac' => cac,'cbc' => cbc).text +  colum + 
            element.xpath('cac:BrandName','cac' => cac,'cbc' => cbc).text +  colum + # Marca
            element.xpath('cac:OriginCountry','cac' => cac,'cbc' => cbc).text +  colum + # Pais de origen
            # Nª de Posicion que el Item comprado tiene en la Orden de Compra
            element.xpath('cac:OrderLineReference/cbc:LineID','cac' => cac,'cbc' => cbc).text  
            strtrama = strtrama + "<br>"
             #DESCRIPCION DEL ITEM DEDI DEDI
            element.xpath("cac:Item", 'cac' => cac  ).each do |item|
                  strtrama = strtrama + "<b>DEDI|</b>" +
                  item.xpath('cbc:Description','cbc' => cbc).text + "|"   # Descripcion
                  strtrama = strtrama + "<br>"
            end
             #DESCUENTOS Y RECARGOS DEL ITEM DEDR
             element.xpath("cac:AllowanceCharge", 'cac' => cac ).each do |itemcharge|
                 strtrama = strtrama + "<b>DEDR|</b>" +
                 itemcharge.xpath('cbc:ChargeIndicator','cac' => cac,'cbc' => cbc).text + "|" + # Indicador de Tipo
                 itemcharge.xpath('cbc:Amount','cac' => cac,'cbc' => cbc).text   # Monto Descuento o Recargo
                 strtrama = strtrama + "<br>"
             end
           #IMPUESTOS DEL ITEM DEIM 
		element.xpath("cac:TaxTotal", 'cac' => cac  ).each do |itemtax|
		    strtrama = strtrama + "<b>DEIM|</b>" +
		    itemtax.xpath('cbc:TaxAmount','cac' => cac,'cbc' => cbc).text + "|" + # Importe total de un tributo para este item
		    # Base Imponible (IGV, IVAP, Otros = Q x VU - Descuentos + ISC  ) 
		    itemtax.xpath('cac:TaxSubtotal/cbc:TaxableAmount','cac' => cac,'cbc' => cbc).text + "|" +
		    # Importe explÌcito a tributar ( = Tasa Porcentaje * Base Imponible)
		    itemtax.xpath('cac:TaxSubtotal/cbc:TaxAmount','cac' => cac,'cbc' => cbc).text + "|" + 
		    itemtax.xpath('cac:TaxSubtotal/cbc:Percent','cac' => cac,'cbc' => cbc).text + "|" + # Tasa Impuesto
		    itemtax.xpath('cac:TaxSubtotal/cbc:TaxCategory/cbc:ID','cac' => cac,'cbc' => cbc).text + "|" + # Tipo de Impuesto
		    # AfectaciÛn del IGV
		    itemtax.xpath('cac:TaxSubtotal/cac:TaxCategory/cbc:TaxExemptionReasonCode','cac' => cac,'cbc' => cbc).text + "|" + 
		    itemtax.xpath('cac:TaxSubtotal/cac:TaxCategory/cbc:TierRange','cac' => cac,'cbc' => cbc).text + "|" + # Sistema de ISC
		    # IdentificaciÛn del tributo
		    itemtax.xpath('cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme/cbc:ID','cac' => cac,'cbc' => cbc).text + "|" +
                    # Nombre del Tributo
		    itemtax.xpath('cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme/cbc:Name','cac' => cac,'cbc' => cbc).text + "|" +
		    # CÛdigo del Tipo de Tributos
		    itemtax.xpath('cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme/cbc:TaxTypeCode','cac' => cac,'cbc' => cbc).text + "|" 
		    strtrama = strtrama + "<br>"
		end

        end

  
         #IMPUESTOS GLOBALES
            xml_doc.xpath("//cac:TaxTotal", 'cac' => cac,'cbc' => cbc  ).each do |element|

               if element.parent.name != parentline
                   strtrama = strtrama + "<b>DI|</b>" +
                 element.xpath('cbc:TaxAmount','cac' => cac,'cbc' => cbc).text + "|" + # Sumatoria Tributo (IGV+ISC+ Otros)
                 # Sumatoria por Tributo (IGV,ISC, Otros)
                element.xpath('cac:TaxSubtotal/cbc:TaxAmount','cac' => cac,'cbc' => cbc).text + "|" +
                 # Identificación del tributo
                element.xpath('cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme/cbc:ID','cac' => cac,'cbc' => cbc).text + "|" + 
                 # Nombre del Tributo
               element.xpath('cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme/cbc:Name','cac' => cac,'cbc' => cbc).text + "|" + 
                 # Código del Tipo de Tributov            
               element.xpath('cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme/cbc:TaxTypeCode','cac' => cac,'cbc' => cbc).text + "|"
                 strtrama = strtrama + "<br>"
               end
            end

         #REFERENCIAS A FACTURAS 
            xml_doc.xpath("//cac:InvoiceDocumentReference", 'cac' => cac,'cbc' => cbc  ).each do |element| 
                   strtrama = strtrama + "<b>RE|</b>" +
                   # Serie y número del documento que modifica (Factura)
                   element.xpath('cbc:ID','cac' => cac,'cbc' => cbc).text + "|" + 
                   #Fecha de emisión
                   element.xpath('cbc:IssueDate','cac' => cac,'cbc' => cbc).text + "|" + 
                   #Tipo de documento del documento que modifica (Factura)
                   element.xpath('cbc:DocumentTypeCode','cac' => cac,'cbc' => cbc).text + "|" +     
                   #(Tipo de documento - Catálogo No. 12)
                   element.xpath('cbc:DocumentType','cac' => cac,'cbc' => cbc).text      
                   strtrama = strtrama + "<br>"
            end    

     #REFERENCIAS A GUIAS  
            xml_doc.xpath("//cac:DespatchDocumentReference", 'cac' => cac,'cbc' => cbc  ).each do |element| 
                   strtrama = strtrama + "<b>RE|</b>" + "|" + "|" + "|" +
                   # En el caso de Guías de Remisión Número de guía: serie - número de documento
                   element.xpath('cbc:ID','cac' => cac,'cbc' => cbc).text + "|" + 
                   #En el caso de Guías de Remisión Tipo de Documento
                   element.xpath('cbc:DocumentTypeCode','cac' => cac,'cbc' => cbc).text + "|" 
                   strtrama = strtrama + "<br>"
            end  

     #REFERENCIAS A OTROS DOCUMENTOS   
            xml_doc.xpath("//cac:AdditionalDocumentReference", 'cac' => cac,'cbc' => cbc  ).each do |element| 
                   strtrama = strtrama + "<b>RE|</b>" +
                   # Serie y número del documento que referencia la factura
                   element.xpath('cbc:ID','cac' => cac,'cbc' => cbc).text + "|" + 
                   #Fecha de emisión
                   element.xpath('cbc:IssueDate','cac' => cac,'cbc' => cbc).text + "|" + 
                   #Tipo de documento del documento que modifica (Factura)
                   element.xpath('cbc:DocumentTypeCode','cac' => cac,'cbc' => cbc).text + "|" 
                   strtrama = strtrama + "<br>"
            end  

     #Descuentos y Recargos Globales   
            xml_doc.xpath("//cac:AllowanceCharge", 'cac' => cac).each do |element| 
                   if element.parent.name    != parentline

		           strtrama = strtrama + "<b>DR|</b>" +
		           # Tipo de Movimiento D/R
		           element.xpath('cbc:ChargeIndicator','cbc' => cbc).text + "|" + 
		           #Código Motivo D/R
		           element.xpath('cbc:AllowanceChargeReasonCode','cbc' => cbc).text + "|" + 
		           #TGlosa D/R
		           element.xpath('cbc:AllowanceChargeReason','cac' => cac,'cbc' => cbc).text + "|" +  
		           #Moneda
		           element.xpath('cbc:Amount [@currencyID]','cac' => cac,'cbc' => cbc).attribute('currencyID') + "|" +  
		           #Monto D/R
		           element.xpath('cbc:Amount','cbc' => cbc).text + "|" +  
		           #Identificación Tributo
		           element.xpath('cac:TaxCategory/cac:TaxScheme/cbc:ID','cac' => cac,'cbc' => cbc).text + "|" +  
		           #Nombre del Tributo
		           element.xpath('cac:TaxCategory/cac:TaxScheme/cbc:Name','cac' => cac,'cbc' => cbc).text + "|" +  
		           #Código Tipo de Tributo
		           element.xpath('cac:TaxCategory/cac:TaxScheme/cbc:TaxTypeCode','cac' => cac,'cbc' => cbc).text + "|" +  
		           #Factor
		           element.xpath('cbc:MultiplierFactorNumeric','cac' => cac,'cbc' => cbc).text + "|" +  
		           #Monto Base
		           element.xpath('cbc:BaseAmount','cac' => cac,'cbc' => cbc).text + "|"  

		           strtrama = strtrama + "<br>"
                  end
            end  

        #FORMA DE PAGO   
            xml_doc.xpath("//cac:PaymentMeans", 'cac' => cac,'cbc' => cbc  ).each do |element| 
                   strtrama = strtrama + "<b>FP|</b>" +
                   # Forma de Pago
                   element.xpath('cbc:PaymentMeansCode','cac' => cac,'cbc' => cbc).text + "|" + 
                   #Fecha de Vencimiento de Pago
                   element.xpath('cbc:PaymentDueDate','cac' => cac,'cbc' => cbc).text + "|" + 
                   #Identificador de Forma de Pago
                   element.xpath('cbc:ID','cac' => cac,'cbc' => cbc).text + "|" 

                 
                   strtrama = strtrama + "<br>"
            end  
     
 #ANTICIPOS Y PREPAGOS   
           
            xml_doc.xpath("//cac:PrepaidPayment", 'cac' => cac,'cbc' => cbc  ).each do |element| 
                   strtrama = strtrama + "<b>PP|</b>" +
                   # ID del Anticipo
                   element.xpath('cbc:ID','cbc' => cbc).text + "|" +
                   # Monto del PrePago
                   element.xpath('cbc:PaidAmount','cbc' => cbc).text + "|" +
                   
                   # Fecha de recepción
                   element.xpath('cbc:ReceivedDate','cac' => cac,'cbc' => cbc).text + "|" + 
                   #Fecha de Pago
                   element.xpath('cbc:PaidDate','cac' => cac,'cbc' => cbc).text + "|"  + 
                   #Hora de Pago
                   " " +  "|"  + 
		   #Tipo de Documento 
                  element.xpath('cbc:ID [@schemeID]','cac' => cac,'cbc' => cbc).attribute('schemeID') + "|" + 
		   #Serie - Correlativo 
                  element.xpath('cbc:ID','cac' => cac,'cbc' => cbc).text + "|" + 
		   #Tipo de Documento de Identidad del Emisor del Anticipo
                  element.xpath('cbc:InstructionID [@schemeID]','cac' => cac,'cbc' => cbc).attribute('schemeID') + "|" + 
		  #Numero de Identidad del Emisor del Anticipo
                  element.xpath('cbc:InstructionID','cac' => cac,'cbc' => cbc).text + "|" 

                                  
                   strtrama = strtrama + "<br>"
            end  
            
            #MULTIPLACA
             
              contador =1
            xml_doc.xpath("//sac:SUNATCosts/cac:RoadTransport", 'sac' => sac,'cac' => cac).each do |element| 
	            
	              if contador == 1    
                   strtrama = strtrama + "<b>MP|</b>"  
                  end    
                   contador += 1
                   # ID del Anticipo
                  strtrama = strtrama + element.xpath('cbc:LicensePlateID','cbc' => cbc).text + ","                          
                  
                   if contador == 8 
	                  contador = 1
	                  strtrama = strtrama +  "<br>"
	               end    
                                   
                   
            end
            
            

#CAMPOS PERSONALIZADOS 

            xml_doc.xpath("//CustomText/Text").each do |element|
                   strtrama = strtrama + "<b>PE|</b>" + element.attribute('name') + "|" + element.text + "|" + "<br>"
             end

            xml_doc.xpath("//CustomText/Section").each do |section|
                    strtrama = strtrama + "<b>PES|</b>" + section.attribute('name') + "<br>"
                     section.xpath('Detail').each do  |detail|
                        strtrama = strtrama + "<b>PESD|</b>" + detail.xpath('Value')[0].text  + "|" + detail.xpath('Value')[1].text + "<br>"
                     end 
             end


 return strtrama



  end

    def retornartrama(nombre)
        strtrama = "Hola Mundo soy " + nombre
        return strtrama
    end
end
