Attribute VB_Name = "Module1"
Sub PickMovie()
    Dim answer As Integer
    Dim listCheck As Boolean
    Dim tblData As Variant
    Dim LO As ListObject
    Dim isListFull As Boolean
    Dim checkMovieList As Boolean
    
    isListFull = True
    checkMovieList = False
    Set LO = Sheets("Movie List").ListObjects("MovieList")
    
    For i = 1 To 2
    
        tblData = LO.DataBodyRange.Columns(i)
        tblData = Application.Transpose(tblData)
        
        For x = 1 To 5
        
            If tblData(x) <> "" Then
                checkMovieList = True
            Else
                isListFull = False
            End If
        
        Next x
    
    Next i
    
    If checkMovieList = True Then
        answer = MsgBox("Would you like to pick a card?", vbQuestion + vbYesNo + vbDefaultButton2, "T&T MOVIE LIST PICKER")
    Else
        MsgBox "No movies currently in the movie list", , "ERROR"
        Exit Sub
    End If
    
    If answer = vbYes And checkMovieList = True Then
    
        If isListFull = True Then
            Call createNextSeries
            Call createNextSeriesStats
        End If
    
        'Call updateTotalStats
    
        Dim MovieTitle As String
        Dim random_num
        Dim arrIndex As Integer
        Dim arrColumn As Integer
        Dim rowIndex As Integer
        Dim displayNum As Integer
        
        While MovieTitle = ""
            random_num = Int((10 * Rnd) + 1)
           
            If (random_num > 5) Then
                arrIndex = random_num - 5
                arrColumn = 2
            Else
                arrIndex = random_num
                arrColumn = 1
            End If
           
            MovieTitle = getMovie(arrIndex, arrColumn)
        Wend
        
        If arrColumn = 1 Then
            displayNum = random_num * 2 - 1
        Else
            displayNum = (random_num - 5) * 2
        End If

        MsgBox "You picked card #" & displayNum & "!", , "T&T MOVIE PICKER"
        MsgBox "You have chosen '" & MovieTitle & "'", , "T&T MOVIE LIST"
        
        Call removeFromList(arrIndex, arrColumn)
        
        rowIndex = addToStats(MovieTitle, arrColumn)
        
    End If
    
End Sub

Function getMovie(arrIndex, arrColumn) As String

    Dim tblData As Variant
    Dim LO As ListObject
    
    Set LO = Sheets("Movie List").ListObjects("MovieList")
    tblData = LO.DataBodyRange.Columns(arrColumn)
    tblData = Application.Transpose(tblData)
    
    getMovie = tblData(arrIndex)

End Function

Sub removeFromList(arrIndex, arrColumn)

    Dim tblData As Variant
    Dim LO As ListObject
    Dim cellAddr
    
    Set LO = Sheets("Movie List").ListObjects("MovieList")

    cellAddr = LO.Range.Cells(arrIndex, arrColumn).Offset(1, 0).Address
    
    Sheets("Movie List").Range(cellAddr).ClearContents

End Sub

Function addToStats(MovieTitle, arrColumn) As Integer

    Dim lastTbl As String
    Dim LO As ListObject
    Dim rowIndex As Integer
    Dim fromColumnText As String
    
    If arrColumn = 2 Then
        fromColumnText = "Victoria"
    Else
        fromColumnText = "Tony"
    End If
    
    lastTbl = "Series_" & Sheets("Movie Series").ListObjects.Count
    Set LO = Sheets("Movie Series").ListObjects(lastTbl)
    rowIndex = 1
    
    While LO.Range.Cells(rowIndex + 1, 2).Value <> ""
        rowIndex = rowIndex + 1
    Wend
    
    If rowIndex > 10 Then
    
        Call createNextSeries
        Call createNextSeriesStats
        
        lastTbl = "Series_" & Sheets("Movie Series").ListObjects.Count
        Set LO = Sheets("Movie Series").ListObjects(lastTbl)
        rowIndex = 1
        
        While LO.Range.Cells(rowIndex + 1, 2).Value <> ""
            rowIndex = rowIndex + 1
        Wend
    
    End If

    Set addedRow = LO.ListRows(rowIndex)
    With addedRow
        .Range(1) = Format(Date, "mm/dd/yyyy")
        .Range(2) = MovieTitle
        .Range(3) = fromColumnText
    End With
    
    addToStats = rowIndex

End Function

Function checkMovieList() As Boolean

    Dim tblData As Variant
    Dim LO As ListObject
    Dim isListFull As Boolean
    
    isListFull = True
    checkMovieList = False
    Set LO = Sheets("Movie List").ListObjects("MovieList")
    
    For i = 1 To 2
    
        tblData = LO.DataBodyRange.Columns(i)
        tblData = Application.Transpose(tblData)
        
        For x = 1 To 5
        
            If tblData(x) <> "" Then
                checkMovieList = True
            Else
                isListFull = False
            End If
        
        Next x
    
    Next i
    
    If isListFull = True Then
        Call createNextSeries
        Call createNextSeriesStats
    End If

End Function

Sub createNextSeries()

    Dim lastTbl As String
    Dim nextTblCol As Integer
    Dim nextTblRow As Integer
    Dim LO As ListObject

    lastTbl = Sheets("Movie Series").ListObjects.Count
    Set LO = Sheets("Movie Series").ListObjects("Series_" & lastTbl)

    nextTblCol = LO.Range.Cells(1, 1).Column + 5
    nextTblRow = LO.Range.Cells(1, 1).Row
    
    If nextTblCol > 12 Then
        nextTblCol = 2
        nextTblRow = nextTblRow + 13
    End If
    
    lastTbl = Sheets("Movie Series").ListObjects.Count + 1
    
    With Sheets("Movie Series")
        .ListObjects.add(xlSrcRange, Sheets("Movie Series").Range(Sheets("Movie Series").Cells(nextTblRow, nextTblCol), Sheets("Movie Series").Cells(nextTblRow + 9, nextTblCol + 3)), , xlNo).Name = "Series_" & lastTbl
        Set LO = .ListObjects("Series_" & lastTbl)
        LO.HeaderRowRange.Cells(1, 1) = "Date"
        LO.HeaderRowRange.Cells(1, 2) = "Movie"
        LO.HeaderRowRange.Cells(1, 3) = "From"
        LO.HeaderRowRange.Cells(1, 4) = "Rating"
        LO.AutoFilter.ShowAllData
    End With
    
    With Sheets("Movie Series").Range(Sheets("Movie Series").Cells(nextTblRow - 1, nextTblCol), Sheets("Movie Series").Cells(nextTblRow - 1, nextTblCol + 3))
        .Merge
        .BorderAround xlContinuous, xlThick
    End With
    With Sheets("Movie Series").Cells(nextTblRow - 1, nextTblCol)
        .Value = "SERIES " & lastTbl
        .Font.Name = "Movieboards"
        .Interior.Color = RGB(254, 224, 148)
        .Font.Size = 18
    End With
    
    Sheets("Movie Series").Range(Sheets("Movie Series").Cells(nextTblRow - 1, nextTblCol), Sheets("Movie Series").Cells(nextTblRow - 1, nextTblCol + 3)).HorizontalAlignment = xlCenter
    Sheets("Movie Series").Range(Sheets("Movie Series").Cells(nextTblRow, nextTblCol), Sheets("Movie Series").Cells(nextTblRow + 10, nextTblCol)).Interior.Color = RGB(255, 0, 0)
    Sheets("Movie Series").Range(Sheets("Movie Series").Cells(nextTblRow, nextTblCol + 1), Sheets("Movie Series").Cells(nextTblRow + 10, nextTblCol + 1)).Interior.Color = RGB(255, 255, 255)
    Sheets("Movie Series").Range(Sheets("Movie Series").Cells(nextTblRow, nextTblCol + 2), Sheets("Movie Series").Cells(nextTblRow + 10, nextTblCol + 2)).Interior.Color = RGB(255, 0, 0)
    Sheets("Movie Series").Range(Sheets("Movie Series").Cells(nextTblRow, nextTblCol + 3), Sheets("Movie Series").Cells(nextTblRow + 10, nextTblCol + 3)).Interior.Color = RGB(255, 255, 255)
    With Sheets("Movie Series").Range(Sheets("Movie Series").Cells(nextTblRow, nextTblCol), Sheets("Movie Series").Cells(nextTblRow + 10, nextTblCol + 3))
        .Font.Color = RGB(0, 0, 0)
        .Font.Bold = False
        .Font.Name = "Bernard MT Condensed"
        .Borders.LineStyle = xlContinuous
    End With
    With Sheets("Movie Series").Range(Sheets("Movie Series").Cells(nextTblRow, nextTblCol), Sheets("Movie Series").Cells(nextTblRow, nextTblCol + 3))
        .AutoFilter
        .Font.Bold = False
        .Borders(xlEdgeBottom).Weight = xlThick
    End With
    Sheets("Movie Series").Range(Sheets("Movie Series").Cells(nextTblRow, nextTblCol), Sheets("Movie Series").Cells(nextTblRow + 10, nextTblCol + 3)).Borders(xlEdgeRight).Weight = xlThick
    Sheets("Movie Series").Range(Sheets("Movie Series").Cells(nextTblRow, nextTblCol), Sheets("Movie Series").Cells(nextTblRow + 10, nextTblCol + 3)).Borders(xlEdgeLeft).Weight = xlThick
    Sheets("Movie Series").Range(Sheets("Movie Series").Cells(nextTblRow, nextTblCol), Sheets("Movie Series").Cells(nextTblRow + 10, nextTblCol + 3)).Borders(xlEdgeBottom).Weight = xlThick

End Sub


Sub createNextSeriesStats()

    Dim lastTbl As String
    Dim nextTblCol As Integer
    Dim nextTblRow As Integer
    Dim LO As ListObject

    lastTbl = Sheets("Movie Series").ListObjects.Count
    Set LO = Sheets("Movie Series").ListObjects("Series_" & lastTbl)

    nextTblCol = LO.Range.Cells(1, 1).Column
    nextTblRow = LO.Range.Cells(1, 1).Row + 2
    
    If nextTblCol = 7 Then
        nextTblCol = 8
    ElseIf nextTblCol = 12 Then
        nextTblCol = 14
    End If
    
    With Sheets("Movie Stats").Range(Sheets("Movie Stats").Cells(nextTblRow - 1, nextTblCol), Sheets("Movie Stats").Cells(nextTblRow - 1, nextTblCol + 4))
        .Merge
        .Interior.Color = RGB(0, 0, 0)
        .Value = "(Series_" & lastTbl & ")"
        .Font.Color = RGB(255, 0, 0)
        .Borders.LineStyle = xlContinuous
        .Font.Size = 18
        .Font.Name = "Showtime"
    End With
    
    With Sheets("Movie Stats").Range(Sheets("Movie Stats").Cells(nextTblRow, nextTblCol), Sheets("Movie Stats").Cells(nextTblRow, nextTblCol + 1))
        .Borders.LineStyle = xlContinuous
        .Merge
        .Value = "Best Overall"
        .Font.Name = "Bernard MT Condensed"
    End With
    With Sheets("Movie Stats").Range(Sheets("Movie Stats").Cells(nextTblRow + 1, nextTblCol), Sheets("Movie Stats").Cells(nextTblRow + 2, nextTblCol + 1))
        .Merge
        .Formula = "=IF(SUMIF(Series_" & lastTbl & "[From]," & Chr(34) & "Tony" & Chr(34) & ",Series_" & lastTbl & "[Rating]) > SUMIF(Series_" & lastTbl & "[From]," & Chr(34) & "Victoria" & Chr(34) & ",Series_" & lastTbl & "[Rating]), " & Chr(34) & "Tony" & Chr(34) & ", " & Chr(34) & "Victoria" & Chr(34) & ")"
        .Font.Size = 18
    End With
    With Sheets("Movie Stats").Range(Sheets("Movie Stats").Cells(nextTblRow + 3, nextTblCol), Sheets("Movie Stats").Cells(nextTblRow + 4, nextTblCol + 1))
        .Merge
        .Formula = "=MAX(SUMIF(Series_" & lastTbl & "[From]," & Chr(34) & "Tony" & Chr(34) & ",Series_" & lastTbl & "[Rating]),SUMIF(Series_" & lastTbl & "[From]," & Chr(34) & "Victoria" & Chr(34) & ",Series_" & lastTbl & "[Rating]))&" & Chr(34) & "/" & Chr(34) & "&10*COUNTIF(Series_" & lastTbl & "[From]," & Cells(nextTblRow + 1, nextTblCol).Address & ")"
        .Font.Size = 18
    End With
    Sheets("Movie Stats").Range(Sheets("Movie Stats").Cells(nextTblRow + 1, nextTblCol), Sheets("Movie Stats").Cells(nextTblRow + 4, nextTblCol + 1)).BorderAround xlContinuous
    
    With Sheets("Movie Stats").Cells(nextTblRow, nextTblCol + 2)
        .Borders.LineStyle = xlContinuous
        .Value = "Best Movie"
        .Font.Name = "Bernard MT Condensed"
    End With
    With Sheets("Movie Stats").Range(Sheets("Movie Stats").Cells(nextTblRow + 1, nextTblCol + 2), Sheets("Movie Stats").Cells(nextTblRow + 2, nextTblCol + 2))
        .Merge
        .Formula = "=XLOOKUP(MAX(Series_" & lastTbl & "[Rating]),Series_" & lastTbl & "[Rating],Series_" & lastTbl & "[Movie])"
        .Font.Size = 12
        .Font.Bold = True
    End With
    With Sheets("Movie Stats").Cells(nextTblRow + 3, nextTblCol + 2)
        .Merge
        .Formula = "=MAX(Series_" & lastTbl & "[Rating])"
        .Font.Size = 11
    End With
    With Sheets("Movie Stats").Cells(nextTblRow + 4, nextTblCol + 2)
        .Merge
        .Formula = "=XLOOKUP(MAX(Series_" & lastTbl & "[Rating]),Series_" & lastTbl & "[Rating],Series_" & lastTbl & "[From])"
        .Font.Size = 11
    End With
    Sheets("Movie Stats").Range(Sheets("Movie Stats").Cells(nextTblRow + 1, nextTblCol + 2), Sheets("Movie Stats").Cells(nextTblRow + 4, nextTblCol + 2)).BorderAround xlContinuous
    
    With Sheets("Movie Stats").Range(Sheets("Movie Stats").Cells(nextTblRow, nextTblCol + 3), Sheets("Movie Stats").Cells(nextTblRow, nextTblCol + 4))
        .Borders.LineStyle = xlContinuous
        .Merge
        .Value = "Total"
        .Font.Name = "Bernard MT Condensed"
    End With
    With Sheets("Movie Stats").Range(Sheets("Movie Stats").Cells(nextTblRow + 1, nextTblCol + 3), Sheets("Movie Stats").Cells(nextTblRow + 4, nextTblCol + 4))
        .Borders.LineStyle = xlContinuous
        .Merge
        .Formula = "=SUM(Series_" & lastTbl & "[Rating])&" & Chr(34) & "/" & Chr(34) & "&10*COUNTIF(Series_" & lastTbl & "[Rating]," & Chr(34) & ">0" & Chr(34) & ")"
        .Font.Size = 26
    End With
    
    With Sheets("Movie Stats").Range(Sheets("Movie Stats").Cells(nextTblRow + 5, nextTblCol), Sheets("Movie Stats").Cells(nextTblRow + 5, nextTblCol + 1))
        .Borders.LineStyle = xlContinuous
        .Merge
        .Value = "Worst Overall"
        .Font.Name = "Bernard MT Condensed"
    End With
    With Sheets("Movie Stats").Range(Sheets("Movie Stats").Cells(nextTblRow + 6, nextTblCol), Sheets("Movie Stats").Cells(nextTblRow + 7, nextTblCol + 1))
        .Merge
        .Formula = "=IF(SUMIF(Series_" & lastTbl & "[From]," & Chr(34) & "Tony" & Chr(34) & ",Series_" & lastTbl & "[Rating]) > SUMIF(Series_" & lastTbl & "[From]," & Chr(34) & "Victoria" & Chr(34) & ",Series_" & lastTbl & "[Rating]), " & Chr(34) & "Victoria" & Chr(34) & ", " & Chr(34) & "Tony" & Chr(34) & ")"
        .Font.Size = 18
    End With
    With Sheets("Movie Stats").Range(Sheets("Movie Stats").Cells(nextTblRow + 8, nextTblCol), Sheets("Movie Stats").Cells(nextTblRow + 9, nextTblCol + 1))
        .Merge
        .Formula = "=MIN(SUMIF(Series_" & lastTbl & "[From]," & Chr(34) & "Tony" & Chr(34) & ",Series_" & lastTbl & "[Rating]),SUMIF(Series_" & lastTbl & "[From]," & Chr(34) & "Victoria" & Chr(34) & ",Series_" & lastTbl & "[Rating]))&" & Chr(34) & "/" & Chr(34) & "&10*COUNTIF(Series_" & lastTbl & "[From],H15)"
        .Font.Size = 18
    End With
    Sheets("Movie Stats").Range(Sheets("Movie Stats").Cells(nextTblRow + 6, nextTblCol), Sheets("Movie Stats").Cells(nextTblRow + 9, nextTblCol + 1)).BorderAround xlContinuous
    
    With Sheets("Movie Stats").Cells(nextTblRow + 5, nextTblCol + 2)
        .Borders.LineStyle = xlContinuous
        .Value = "Worst Movie"
        .Font.Name = "Bernard MT Condensed"
    End With
    With Sheets("Movie Stats").Range(Sheets("Movie Stats").Cells(nextTblRow + 6, nextTblCol + 2), Sheets("Movie Stats").Cells(nextTblRow + 7, nextTblCol + 2))
        .Merge
        .Formula = "=XLOOKUP(MIN(Series_" & lastTbl & "[Rating]),Series_" & lastTbl & "[Rating],Series_" & lastTbl & "[Movie])"
        .Font.Size = 12
        .Font.Bold = True
    End With
    With Sheets("Movie Stats").Cells(nextTblRow + 8, nextTblCol + 2)
        .Merge
        .Formula = "=MIN(Series_" & lastTbl & "[Rating])"
        .Font.Size = 11
    End With
    With Sheets("Movie Stats").Cells(nextTblRow + 9, nextTblCol + 2)
        .Merge
        .Formula = "=XLOOKUP(MIN(Series_" & lastTbl & "[Rating]),Series_" & lastTbl & "[Rating],Series_" & lastTbl & "[From])"
        .Font.Size = 11
    End With
    Sheets("Movie Stats").Range(Sheets("Movie Stats").Cells(nextTblRow + 6, nextTblCol + 2), Sheets("Movie Stats").Cells(nextTblRow + 9, nextTblCol + 2)).BorderAround xlContinuous
    
    With Sheets("Movie Stats").Range(Sheets("Movie Stats").Cells(nextTblRow + 5, nextTblCol + 3), Sheets("Movie Stats").Cells(nextTblRow + 5, nextTblCol + 4))
        .Borders.LineStyle = xlContinuous
        .Merge
        .Value = "Average"
        .Font.Name = "Bernard MT Condensed"
    End With
    With Sheets("Movie Stats").Range(Sheets("Movie Stats").Cells(nextTblRow + 6, nextTblCol + 3), Sheets("Movie Stats").Cells(nextTblRow + 9, nextTblCol + 4))
        .Borders.LineStyle = xlContinuous
        .Merge
        .Formula = "=ROUND(AVERAGE(Series_" & lastTbl & "[Rating]),1)"
        .Font.Size = 36
    End With
    
    Sheets("Movie Stats").Range(Sheets("Movie Stats").Cells(nextTblRow, nextTblCol), Sheets("Movie Stats").Cells(nextTblRow + 9, nextTblCol + 4)).Interior.Color = RGB(255, 255, 255)

End Sub

Sub updateTotalStats()

    Dim tblCount As Integer
    
    Dim BestSeries As String
    Dim BestSeriesCount As Double
    
    Dim BestMovie As String
    Dim BestMovieCount As Double
    BestMovieCount = 0
    
    Dim BestFrom As String
    Dim WorstFrom As String
    Dim ToraCount As Double
    Dim TonyCount As Double
    ToraCount = 0
    TonyCount = 0
    
    Dim TotalCount As Double
    
    Dim MoviesWatched As String
    MoviesWatched = 0
    
    Dim WorstMovie As String
    Dim WorstMovieCount As Double
    WorstMovieCount = 100
    
    Dim WorstSeries As String
    Dim WorstSeriesCount As Double
    WorstSeriesCount = 100
    
    Dim LO As ListObject
    Dim tblDate As Variant
    Dim tblMovie As Variant
    Dim tblFrom As Variant
    Dim tblRating As Variant

    tblCount = Sheets("Movie Series").ListObjects.Count
    
    For i = 1 To tblCount
    
        Set LO = Sheets("Movie Series").ListObjects("Series_" & i)
        
        tblDate = Application.Transpose(LO.DataBodyRange.Columns(1))
        tblMovie = Application.Transpose(LO.DataBodyRange.Columns(2))
        tblFrom = Application.Transpose(LO.DataBodyRange.Columns(3))
        tblRating = Application.Transpose(LO.DataBodyRange.Columns(4))
        
        If WorksheetFunction.Average(LO.DataBodyRange.Columns(4)) >= BestSeriesCount Then
            BestSeries = "Series " & i
        End If
        BestSeriesCount = WorksheetFunction.Max(WorksheetFunction.Average(LO.DataBodyRange.Columns(4)), BestSeriesCount)
        
        If WorksheetFunction.Average(LO.DataBodyRange.Columns(4)) <= WorstSeriesCount Then
            WorstSeries = "Series " & i
        End If
        WorstSeriesCount = WorksheetFunction.Min(WorksheetFunction.Average(LO.DataBodyRange.Columns(4)), WorstSeriesCount)
        
        For x = 1 To 10
            If tblRating(x) <> "-" And tblRating(x) <> "" Then
            
                If tblRating(x) >= BestMovieCount Then
                    BestMovie = tblMovie(x)
                End If
                BestMovieCount = WorksheetFunction.Max(tblRating(x), BestMovieCount)
                
                If tblRating(x) <= WorstMovieCount Then
                    WorstMovie = tblMovie(x)
                End If
                WorstMovieCount = WorksheetFunction.Min(tblRating(x), WorstMovieCount)
                
                If tblFrom(x) = "Victoria" Then
                    ToraCount = ToraCount + tblRating(x)
                Else
                    TonyCount = TonyCount + tblRating(x)
                End If
                
                MoviesWatched = MoviesWatched + 1
                TotalCount = TotalCount + tblRating(x)
        
            End If
        Next x
            
    Next i
    
    If ToraCount >= TonyCount Then
        BestFrom = "Victoria"
        WorstFrom = "Tony"
    Else
        BestFrom = "Tony"
        WorstFrom = "Victoria"
    End If
    
    Worksheets("Movie Stats").Range("E11").Value = BestSeries
    Worksheets("Movie Stats").Range("G11").Value = BestMovie
    Worksheets("Movie Stats").Range("I11").Value = BestFrom
    Worksheets("Movie Stats").Range("J10").Value = "Average - " & WorksheetFunction.Round(TotalCount / MoviesWatched, 1)
    Worksheets("Movie Stats").Range("J11").Value = "Movies Watched - " & MoviesWatched
    Worksheets("Movie Stats").Range("K11").Value = WorstFrom
    Worksheets("Movie Stats").Range("L11").Value = WorstMovie
    Worksheets("Movie Stats").Range("N11").Value = WorstSeries

End Sub
