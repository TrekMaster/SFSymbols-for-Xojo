#tag Module
Protected Module SystemImage
	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target64Bit)) or  (TargetDesktop and (Target64Bit))
		Function SystemImage(name As String, size As Double, weight As SystemImageWeights = SystemImageWeights.Regular, scale As symbolscale = symbolscale.medium, templateColor As color, fallbackTemplateImage As Picture = Nil) As Picture
		  #If TargetMacOS 
		    Declare Function Alloc Lib "Foundation" Selector "alloc" ( classRef As ptr ) As ptr
		    Declare Sub AutoRelease Lib "Foundation" Selector "autorelease" ( classInstance As ptr )
		    Declare Function NSClassFromString Lib "Foundation" ( clsName As CFStringRef ) As ptr
		    Declare Function ColorWithRGBA Lib "Foundation" Selector "colorWithRed:green:blue:alpha:" ( nscolor As ptr, red As CGFloat, green As CGFloat, blue As CGFloat, alpha As CGFloat ) As ptr
		    Declare Sub SetTemplate Lib "AppKit" Selector "setTemplate:" ( imageObj As ptr, value As Boolean )
		    Declare Sub LockFocus Lib "AppKit" Selector "lockFocus" ( imageObj As ptr )
		    Declare Sub UnlockFocus Lib "AppKit" Selector "unlockFocus" ( imageObj As ptr )
		    Declare Sub Set Lib "Foundation" Selector "set" ( colorObj As ptr )
		    Declare Sub NSRectFillUsingOperation Lib "AppKit" ( rect As NSRect, option As UInteger )
		    
		    Declare Function RepresentationUsingType Lib "AppKit" Selector "representationUsingType:properties:" ( imageRep As ptr, type As UInteger, properties As ptr ) As ptr
		    Declare Function InitWithFocusedView Lib "AppKit" Selector "initWithFocusedViewRect:" ( imageObj As ptr, rect As NSRect ) As ptr
		    
		    Var finalImage As ptr
		    
		    If System.Version >= "11.0" Then
		      
		      If name = "" Then Return Nil
		      
		      Declare Function ImageWithSystemSymbolName Lib "AppKit" Selector "imageWithSystemSymbolName:accessibilityDescription:" ( imgClass As ptr, symbolName As CFStringRef, accesibility As CFStringRef ) As ptr
		      Declare Function ConfigurationWithPointSize Lib "AppKit" Selector "configurationWithPointSize:weight:scale:" ( symbolConfClass As ptr, size As CGFloat, weight As CGFloat, tscale As SymbolScale ) As ptr
		      Declare Function ImageWithSymbolConfiguration Lib "AppKit" Selector "imageWithSymbolConfiguration:" ( imgClass As ptr, config As ptr ) As ptr
		      
		      Var nsimage As ptr = NSClassFromString( "NSImage" )
		      Var orImage As ptr = ImageWithSystemSymbolName( nsimage, name,"" )
		      Var symbolConfClass As ptr = NSClassFromString( "NSImageSymbolConfiguration" )
		      
		      // Getting the weight as the required SystemImageWeight float
		      
		      Var tWeight As CGFloat = SystemImageWeight( weight )
		      
		      // Creating a configuration obj for the Glyph
		      
		      Var symbolConf As ptr = ConfigurationWithPointSize( symbolConfClass, size, tWeight, scale )
		      
		      // Getting the final NSImage from the Glyph + Conf (still in vectorial format)
		      finalImage = ImageWithSymbolConfiguration( orImage, symbolConf )
		      
		    End If
		    // Can't create image from received glyph name, so we return Nil if fallback is not provided
		    // or colorize the fallback image if there is one
		    If finalImage = Nil Then
		      
		      If fallbackTemplateImage = Nil Then Return Nil
		      
		      Var fallbackData As MemoryBlock = fallbackTemplateImage.ToData( Picture.Formats.PNG )
		      Var fallbackDataPtr As ptr = fallbackData
		      
		      Declare Function DataWithBytesLength Lib "Foundation" Selector "dataWithBytes:length:" ( dataClass As ptr, data As ptr, length As UInteger ) As ptr
		      
		      If fallbackData <> Nil And fallbackData.Size > 0 Then
		        
		        Var NSDataClass As ptr = NSClassFromString( "NSData" )
		        Var NSDataObj As ptr = DataWithBytesLength( NSDataclass, fallbackDataPtr, fallbackData.Size )
		        
		        If NSDataObj <> Nil Then
		          
		          Declare Function InitWithData Lib "AppKit" Selector "initWithData:" ( imageInstance As ptr, data As ptr ) As ptr
		          
		          Var NSImageClass As ptr = NSClassFromString( "NSImage" )
		          
		          finalImage = Alloc( NSImageClass )
		          finalImage = InitWithData( finalImage, NSDataObj )
		          
		          AutoRelease( NSDataObj )
		          
		        End If
		        
		      End If
		      
		    End If
		    
		    If finalImage = Nil Then Return Nil
		    
		    Var c As Color
		    Var nscolor As ptr
		    
		    LockFocus( finalImage )
		    
		    // Applying tint to the image if we receive a valid ColorGroup object
		    
		    c = templateColor
		    
		    nscolor = NSClassFromString( "NSColor" )
		    Var tColor As ptr = ColorWithRGBA( nscolor, c.Red / 255.0, c.Green / 255.0, c.Blue / 255.0, 1.0 - c.Alpha / 255.0 )
		    
		    // We need to set the Template property of the NSImage to False in order to colorize it.
		    If templateColor <> Color.Black Then
		      SetTemplate( finalImage, False )
		    Else
		      SetTemplate( finalImage, True )
		    End If
		    
		    Declare Function ImageSize Lib "AppKit" Selector "size" ( imageObjt As ptr ) As NSSize
		    
		    Var tRect As NSRect
		    
		    tRect.Origin.x = 0
		    tRect.Origin.y = 0
		    tRect.RectSize = ImageSize( finalImage )
		    
		    
		    Set(tColor)
		    NSRectFillUsingOperation( tRect, 3 )
		    
		    
		    // Getting bitmap image representation in order to extract the data as PNG.
		    
		    Var NSBitmapImageRepClass As ptr = NSClassFromString( "NSBitmapImageRep" )
		    Var NSBitmapImageRepInstance As ptr = Alloc( NSBitmapImageRepClass )
		    Var newRep As ptr = InitWithFocusedView( NSBitmapImageRepInstance, tRect )
		    
		    UnlockFocus( finalImage )
		    
		    Var data As ptr = RepresentationUsingType( newRep, 4, Nil ) // 4 = PNG
		    
		    AutoRelease( newRep )
		    AutoRelease( nscolor )
		    
		    // Getting image data to generate the Picture object in the Xojo side
		    
		    Declare Function DataLength Lib "Foundation" Selector "length" ( obj As ptr ) As Integer
		    Declare Sub GetDataBytes Lib "Foundation" Selector "getBytes:length:" ( obj As ptr, buff As ptr, Len As Integer )
		    
		    // We need to get the length of the raw data…
		    Var dlen As Integer = DataLength( data )
		    
		    // …in order to create a memoryblock with the right size
		    Var mb As New MemoryBlock( dlen )
		    Var mbPtr As ptr = mb
		    
		    // And now we can dump the PNG data from the NSDATA objecto to the memoryblock
		    GetDataBytes( data, mbPtr, dlen )
		    
		    // In order to create a Xojo Picture from it
		    Return Picture.FromData( mb )
		    
		    
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetDesktop and (Target64Bit))
		Function SystemImage(name As String, size As Double, weight As SystemImageWeights = SystemImageWeights.Regular, scale As symbolscale = symbolscale.medium, templateColor As ColorGroup = Nil, fallbackTemplateImage As Picture = Nil) As Picture
		  Var c As Color
		  
		  If templateColor <> Nil Then
		    c = templateColor
		  End If
		  
		  Return SystemImage( name, size, weight, scale, c, fallbackTemplateImage )
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetDesktop and (Target64Bit))
		Sub SystemImageControl(name as String, size as Double, weight as SystemImageWeights = SystemImageWeights.Regular, scale as SymbolScale = SymbolScale.small, controlHandler as Ptr, fallbackTemplateImage as Picture, nSegment as Integer = -1)
		  #If TargetMacOS 
		    
		    Declare Function Alloc Lib "Foundation" Selector "alloc" ( classRef As ptr ) As ptr
		    Declare Sub AutoRelease Lib "Foundation" Selector "autorelease" ( classInstance As ptr )
		    
		    Declare Function NSClassFromString Lib "Foundation" ( clsName As CFStringRef ) As ptr
		    Declare Function ImageWithSystemSymbolName Lib "AppKit" Selector "imageWithSystemSymbolName:accessibilityDescription:" ( imgClass As ptr, symbolName As CFStringRef, accesibility As CFStringRef ) As ptr
		    Declare Function ConfigurationWithPointSize Lib "AppKit" Selector "configurationWithPointSize:weight:scale:" ( symbolConfClass As ptr, size As CGFloat, weight As CGFloat, scale As SymbolScale ) As ptr
		    Declare Function ImageWithSymbolConfiguration Lib "AppKit" Selector "imageWithSymbolConfiguration:" ( imgClass As ptr, config As ptr ) As ptr
		    
		    Var finalImage As ptr
		    
		    If System.Version >= "11.0" Then
		      
		      If name = "" Then Exit
		      
		      Var nsimage As ptr = NSClassFromString( "NSImage" )
		      Var orImage As ptr = ImageWithSystemSymbolName( nsimage, name,"" )
		      Var symbolConfClass As ptr = NSClassFromString( "NSImageSymbolConfiguration" )
		      
		      // Getting the weight as the required SystemImageWeight float
		      Var tWeight As CGFloat = SystemImageWeight( weight )
		      
		      // Creating a configuration obj for the Glyph
		      Var symbolConf As ptr = ConfigurationWithPointSize( symbolConfClass, size, tWeight, scale )
		      
		      // Getting the final NSImage from the Glyph + Conf (still in vectorial format)
		      finalImage = ImageWithSymbolConfiguration( orImage, symbolConf )
		      
		    End If
		    
		    If finalImage = Nil Then
		      
		      If fallbackTemplateImage <> Nil Then
		        
		        finalImage = fallbackTemplateImage.CopyOSHandle( Picture.HandleTypes.MacNSImage )
		        
		      End If
		      
		    End If
		    
		    If finalImage <> Nil Then
		      Declare Sub SetTemplate Lib "AppKit" Selector "setTemplate:" ( imageObj As ptr, value As Boolean )
		      SetTemplate( finalImage, True )
		      
		      // We need to know if the received Handler can respond to the setImage message (that is, it's a View)
		      Declare Function RespondsToSelector Lib "/usr/lib/libobjc.A.dylib" Selector "respondsToSelector:" ( obj As ptr, sel As ptr ) As Boolean
		      Declare Function NSSelectorFromString Lib "Foundation" ( sel As CFStringRef ) As ptr
		      Var sel As ptr = NSSelectorFromString( "setImage:" )
		      Var sel2 As ptr = NSSelectorFromString( "setImage:forSegment:" )
		      
		      // We check if it's a valid handler, we have an NSImage object and the handler can receive the "setImage" message
		      If controlHandler <> Nil And finalImage <> Nil And RespondsToSelector( controlHandler, sel ) Then
		        
		        Declare Sub Set Lib "AppKit" Selector "setImage:" ( control As ptr, Image As ptr )
		        // We set the NSImage to the received control
		        Set( controlHandler, finalImage )
		        
		      ElseIf nSegment <> -1 And controlHandler <> Nil And finalImage <> Nil And RespondsToSelector( controlHandler, sel2 ) Then
		        
		        Declare Sub Set Lib "AppKit" Selector "setImage:forSegment:" ( control As ptr, Image As ptr, segment As Integer )
		        // We set the NSImage to the received control
		        Set( controlHandler, finalImage, nSegment )
		        
		        
		      End If
		      
		    End If
		  #EndIf
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SystemImageWeight(weight as SystemImageWeights) As CGFloat
		  Var tWeight As CGFloat = 0
		  
		  Select Case weight
		    
		  Case SystemImageWeights.UltraLight
		    tWeight = -1.00
		  Case SystemImageWeights.Thin
		    tWeight = -0.75
		  Case SystemImageWeights.Light
		    tWeight = -0.50
		  Case SystemImageWeights.Regular
		    tWeight = -0.25
		  Case SystemImageWeights.Medium
		    tWeight = 0.00
		  Case SystemImageWeights.Semibold
		    tWeight = 0.25
		  Case SystemImageWeights.Bold
		    tWeight = 0.50
		  Case SystemImageWeights.Heavy
		    tWeight = 0.75
		  Case SystemImageWeights.Black
		    tWeight = 1.00
		  End Select
		  
		  Return tWeight
		End Function
	#tag EndMethod


	#tag Structure, Name = NSOrigin, Flags = &h0
		X as CGFloat
		Y as CGFloat
	#tag EndStructure

	#tag Structure, Name = NSRect, Flags = &h0
		Origin as NSOrigin
		RectSize as NSSize
	#tag EndStructure

	#tag Structure, Name = NSSize, Flags = &h0
		Height as CGFloat
		Width as CGFloat
	#tag EndStructure


	#tag Enum, Name = SymbolScale, Type = Integer, Flags = &h0
		Small = 1
		  Medium = 2
		Large = 3
	#tag EndEnum

	#tag Enum, Name = SystemImageWeights, Flags = &h0
		UltraLight=0
		  Thin
		  Light
		  Regular
		  Medium
		  Semibold
		  Bold
		  Heavy
		Black
	#tag EndEnum


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
