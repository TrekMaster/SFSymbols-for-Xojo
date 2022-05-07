#tag DesktopWindow
Begin DesktopWindow Window1
   Backdrop        =   0
   BackgroundColor =   &cFFFFFF
   Composite       =   False
   DefaultLocation =   2
   FullScreen      =   False
   HasBackgroundColor=   False
   HasCloseButton  =   True
   HasFullScreenButton=   False
   HasMaximizeButton=   True
   HasMinimizeButton=   True
   Height          =   208
   ImplicitInstance=   True
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   1646258175
   MenuBarVisible  =   False
   MinimumHeight   =   64
   MinimumWidth    =   64
   Resizeable      =   True
   Title           =   "Untitled"
   Type            =   0
   Visible         =   True
   Width           =   330
   Begin Toolbar1 Toolbar11
      Enabled         =   True
      Index           =   -2147483648
      LockedInPosition=   False
      Scope           =   0
      TabPanelIndex   =   0
      Visible         =   True
   End
   Begin DesktopButton Button1
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   False
      Caption         =   ""
      Default         =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      Italic          =   False
      Left            =   228
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   False
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   168
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   35
   End
   Begin DesktopButton Button2
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   False
      Caption         =   ""
      Default         =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      Italic          =   False
      Left            =   275
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   False
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   168
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   35
   End
   BeginDesktopSegmentedButton DesktopSegmentedButton SegmentedButton1
      Enabled         =   True
      Height          =   24
      Index           =   -2147483648
      Left            =   40
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      MacButtonStyle  =   0
      Scope           =   0
      Segments        =   "\n\nFalse\r\n\nFalse\r\n\nFalse"
      SelectionStyle  =   0
      TabIndex        =   2
      TabPanelIndex   =   0
      TabStop         =   False
      Tooltip         =   ""
      Top             =   20
      Transparent     =   False
      Visible         =   True
      Width           =   167
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag Method, Flags = &h0
		Sub ToolbarSetIcon(itemsPtr as Ptr, index as Integer, Icon as Picture)
		  Declare Function objectAtIndex Lib "AppKit" Selector "objectAtIndex:" ( theArray As Ptr, idx As Integer ) As Ptr
		  Declare Sub NSControlImage Lib "AppKit" Selector "setImage:" ( NSControlInstance As Ptr, Assigns inNSImage As ptr )
		  Declare Sub NSImageTemplate Lib "AppKit" Selector "setTemplate:" ( NSImageInstance As ptr, Assigns value As Boolean )
		  
		  Var NSImage, toolbarItemPtr As Ptr
		  
		  ' Get the individual button
		  toolbarItemPtr = objectAtIndex( itemsPtr, Index )
		  
		  ' Turn our picture into an NSImage
		  NSImage = Icon.CopyOSHandle( Picture.HandleTypes.MacNSImage )
		  
		  ' Set the template flag, so that macOS handles the light and dark mode changes.
		  NSImageTemplate( NSImage ) = True
		  
		  ' and assign the image
		  NSControlImage( toolbarItemPtr ) = NSImage
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ToolbarSetIcons()
		  Declare Function tbar Lib "AppKit" Selector "toolbar" ( NSWindow As Ptr ) As Ptr
		  Declare Function items Lib "AppKit" Selector "items" ( NSToolbar As Ptr ) As Ptr
		  
		  ' This part is called once for all of the toolbar, if it was in ToolbarSetIcon it would need to be called repeatedly
		  Var toolbarPtr As Ptr = tbar( Ptr( Handle ) )
		  Var itemsPtr As Ptr = items( toolbarPtr )
		  
		  ' The ItemsPtr is then used to set the icons for each item
		  ToolbarSetIcon( itemsPtr, 0, TBNewImage )
		  ToolbarSetIcon( itemsPtr, 1, TBOpenImage )
		  ToolbarSetIcon( itemsPtr, 2, TBSaveImage )
		  ' and so on for each Toolbar icon...
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		#tag Note
			Property to hold the SFSymbol for the first Toolbar item
		#tag EndNote
		TBNewImage As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			Property to hold the SFSymbol for the second Toolbar item
		#tag EndNote
		TBOpenImage As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			Property to hold the SFSymbol for the third Toolbar item
		#tag EndNote
		TBSaveImage As Picture
	#tag EndProperty


#tag EndWindowCode

#tag Events Toolbar11
	#tag Event
		Sub Opening()
		  ' Generate and save the images in window properties
		  TBNewImage = SystemImage( "macwindow.badge.plus", 36.0, SystemImageWeights.Light, SymbolScale.Small, Color.Black, ToolbarIcon_New )
		  TBOpenImage = SystemImage( "menubar.arrow.up.rectangle", 36.0, SystemImageWeights.Light, SymbolScale.Small, Color.Black, ToolbarIcon_Open )
		  TBSaveImage = SystemImage( "menubar.arrow.down.rectangle", 36.0, SystemImageWeights.Light, SymbolScale.Small, Color.Black, ToolbarIcon_Save )
		  
		  ' Add them to the toolbar
		  ToolbarSetIcons
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events Button1
	#tag Event
		Sub Opening()
		  ' Set the image for the button
		  SystemImageControl( "chevron.left",14.0, SystemImageWeights.Regular,SymbolScale.Medium,Me.Handle, btnIconPrev )
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events Button2
	#tag Event
		Sub Opening()
		  ' Set the image for the button
		  SystemImageControl( "chevron.right",14.0, SystemImageWeights.Regular,SymbolScale.Medium,Me.Handle, btnIconPrev )
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events SegmentedButton1
	#tag Event
		Sub Opening()
		  ' Set the images for the segments
		  SystemImageControl( "text.alignleft", 14.0, SystemImageWeights.Medium, SymbolScale.Small, Me.Handle, segAlign_Left, 0 )
		  SystemImageControl( "text.aligncenter", 14.0, SystemImageWeights.Medium, SymbolScale.Small, Me.Handle, segAlign_Centre, 1 )
		  SystemImageControl( "text.alignright", 14.0, SystemImageWeights.Medium, SymbolScale.Small, Me.Handle, segAlign_Right, 2 )
		End Sub
	#tag EndEvent
#tag EndEvents
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
		Name="Interfaces"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
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
		Name="Width"
		Visible=true
		Group="Size"
		InitialValue="600"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Height"
		Visible=true
		Group="Size"
		InitialValue="400"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinimumWidth"
		Visible=true
		Group="Size"
		InitialValue="64"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinimumHeight"
		Visible=true
		Group="Size"
		InitialValue="64"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaximumWidth"
		Visible=true
		Group="Size"
		InitialValue="32000"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaximumHeight"
		Visible=true
		Group="Size"
		InitialValue="32000"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Type"
		Visible=true
		Group="Frame"
		InitialValue="0"
		Type="Types"
		EditorType="Enum"
		#tag EnumValues
			"0 - Document"
			"1 - Movable Modal"
			"2 - Modal Dialog"
			"3 - Floating Window"
			"4 - Plain Box"
			"5 - Shadowed Box"
			"6 - Rounded Window"
			"7 - Global Floating Window"
			"8 - Sheet Window"
			"9 - Metal Window"
			"11 - Modeless Dialog"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="Title"
		Visible=true
		Group="Frame"
		InitialValue="Untitled"
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasCloseButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasMaximizeButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasMinimizeButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasFullScreenButton"
		Visible=true
		Group="Frame"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Resizeable"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Composite"
		Visible=false
		Group="OS X (Carbon)"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MacProcID"
		Visible=false
		Group="OS X (Carbon)"
		InitialValue="0"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="FullScreen"
		Visible=false
		Group="Behavior"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="DefaultLocation"
		Visible=true
		Group="Behavior"
		InitialValue="2"
		Type="Locations"
		EditorType="Enum"
		#tag EnumValues
			"0 - Default"
			"1 - Parent Window"
			"2 - Main Screen"
			"3 - Parent Window Screen"
			"4 - Stagger"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="Visible"
		Visible=true
		Group="Behavior"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="ImplicitInstance"
		Visible=true
		Group="Windows Behavior"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasBackgroundColor"
		Visible=true
		Group="Background"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="BackgroundColor"
		Visible=true
		Group="Background"
		InitialValue="&cFFFFFF"
		Type="ColorGroup"
		EditorType="ColorGroup"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Backdrop"
		Visible=true
		Group="Background"
		InitialValue=""
		Type="Picture"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MenuBar"
		Visible=true
		Group="Menus"
		InitialValue=""
		Type="DesktopMenuBar"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MenuBarVisible"
		Visible=true
		Group="Deprecated"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="TBNewImage"
		Visible=false
		Group="Behavior"
		InitialValue=""
		Type="Picture"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="TBOpenImage"
		Visible=false
		Group="Behavior"
		InitialValue=""
		Type="Picture"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="TBSaveImage"
		Visible=false
		Group="Behavior"
		InitialValue=""
		Type="Picture"
		EditorType=""
	#tag EndViewProperty
#tag EndViewBehavior
