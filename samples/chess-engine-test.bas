Import Dom From "lib/web/dom.bas"
'Import Console From "lib/web/console.bas"
Import Chess From "https://boxgaming.github.io/three.qbjs/samples/qbjs-chess-engine.bas"
Option Explicit

Dim Shared levels() As String
Dim Shared aiLevel As Integer
GetAILevel

Dim As String mstart, mend, mstr
Do
    Cls
    PrintBoard
    Print
    Input "   Enter location of piece to move (e.g. C2): ", mstart 
    If mstart = "Q" Or mstart = "q" Then Exit Do
    mstr = GetMoves(mstart) 
    If mstr = "" Then
        Color 6: Print "   No available moves for this piece."
        Color 7: Print 
        Print "   Press any key to continue..."
        Sleep
    Else 
        Print "   Available moves: "; mstr
        Input "   Enter destination location (e.g. C4): ", mend 
        If mend = "Q" Or mend = "q" Then Exit Do
        If Not Chess.Move(mstart, mend) Then
            Dim msg As String
            msg = Chess.LastErrorMessage
            Color 6: Print "   "; msg
            Color 7: Print "   Press any key to continue...";
            Sleep
        Else
            Cls
            PrintBoard
            Delay .1
            Chess.AIMove aiLevel - 1
        End If
    End If
Loop Until Chess.IsFinished
If Chess.IsFinished
    Cls
    PrintBoard
End If
Print
Print "   Game Over!";
'Console.Echo Chess.FEN

Function GetMoves (pos As String)
    Dim result As String
    ReDim m(0) As String
    m = Chess.Moves(UCase$(pos))
    Dim i As Integer
    For i = 1 To UBound(m)
        result = result + m(i) + " "
    Next i
    GetMoves = result
End Function

Sub GetAILevel
    levels(1) = "Beginner"
    levels(2) = "Easy"
    levels(3) = "Intermediate"
    levels(4) = "Advanced"
    levels(5) = "Expert"
    Print
    Print " Select a Difficulty Level"
    Dim i As Integer
    For i = 1 To 5
        Print "  -> "; i; "- "; levels(i)
    Next i
    Print
    Input " Enter Difficulty Level 1-5: ", aiLevel
    If aiLevel > 0 And aiLevel < 6 Then
        ' valid
    Else
        aiLevel = 1
        Print " Invalid selection, defaulting to level 1"
        Print
        Print " Press any key to continue..."
        Sleep
    End If 
End Sub

Sub PrintBoard
    Locate 4, 40: Print "Turn:  "; Chess.Turn; "   "
    Locate 6, 40: Print "Level: "; levels(aiLevel)
    Locate 12, 40: Print "Enter 'Q' to Quit"
    If Chess.IsCheckMate Then
        Locate 8, 40: Color 4: Print "Check Mate"
    ElseIf Chess.IsCheck Then
        Locate 8, 40: Color 6: Print "Check"
    End If
    Locate 1, 1
    
    Dim As String bstate(), p, s
    bstate = Chess.BoardPieces
    Dim As Integer rank, file
    Color 7: Print
    Print "     A   B   C   D   E   F   G   H"
    Print "   ";
    Color 8, 7: Print "┌───┬───┬───┬───┬───┬───┬───┬───┐"
    For file = 8 To 1 Step -1
        Color 7, 0: Print " " + file + " ";
        Color 8, 7: Print "│";
        For rank = Asc("A") To Asc("H")
            s = Chr$(rank) + file
            p = bstate(s)
            If p = "" Then p = " "
            Color 8, 7: Print " ";
            If p > "A" And p < "Z" Then Color 15 Else Color 0
            Print p;
            Color 8, 7: Print " │"; 
            Color 7, 0
        Next rank
        Print 
        If file > 1 Then 
            Color 7, 0: Print "   ";
            Color 8, 7: Print "├───┼───┼───┼───┼───┼───┼───┼───┤"
        End If
    Next file
    Color 7, 0: Print "   ";
    Color 8, 7: Print "└───┴───┴───┴───┴───┴───┴───┴───┘"
    Color 7, 0
End Sub