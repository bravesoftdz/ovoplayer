{
This file is part of OvoPlayer
Copyright (C) 2011 Marco Caselli

OvoPlayer is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

}

unit customdrawn_ovoplayer;

{$mode objfpc}{$H+}

interface

uses
  // RTL / FCL
  Classes, SysUtils, Types, Math, fpcanvas,
  // LazUtils
  lazutf8,
  // LCL -> Use only TForm, TWinControl, TCanvas and TLazIntfImage
  Graphics, Controls, LCLType,
  // Others only for types
  StdCtrls, ComCtrls, Forms, ExtCtrls,
  //
  customdrawndrawers, customdrawn_common;

type
  { TCDDrawerOvoPlayer }

  TCDDrawerOvoPlayer = class(TCDDrawerCommon)
  public
    function GetMeasures(AMeasureID: Integer): Integer; override;
    // General drawing routines
    procedure DrawSlider(ADest: TCanvas; ADestPos: TPoint; ASize: TSize; AState: TCDControlState); override;
    // ===================================
    // Common Controls Tab
    // ===================================
    // TCDTrackBar
    procedure DrawTrackBar(ADest: TCanvas; ASize: TSize;
      AState: TCDControlState; AStateEx: TCDPositionedCStateEx); override;
  end;

implementation

function TCDDrawerOvoPlayer.GetMeasures(AMeasureID: Integer): Integer;
begin
  case AMeasureID of
  //
  TCDTRACKBAR_LEFT_SPACING: Result := DPIAdjustment(7);
  TCDTRACKBAR_RIGHT_SPACING: Result := DPIAdjustment(7);
  TCDTRACKBAR_TOP_SPACING: Result := DPIAdjustment(5);
  TCDTRACKBAR_FRAME_HEIGHT: Result := DPIAdjustment(14);
  else
    result := Inherited  GetMeasures(AMeasureID);
  end;
end;


procedure TCDDrawerOvoPlayer.DrawSlider(ADest: TCanvas; ADestPos: TPoint;
  ASize: TSize; AState: TCDControlState);
var
  lRect: TRect;
begin
  lRect := Bounds(ADestPos.X, ADestPos.Y, ASize.CX, ASize.CY);
  ADest.Brush.Color := clLtGray;
  ADest.FillRect(lRect);
  ADest.Frame3d(lRect, clWhite, clGray, 2);
end;


procedure TCDDrawerOvoPlayer.DrawTrackBar(ADest: TCanvas;
  ASize: TSize; AState: TCDControlState; AStateEx: TCDPositionedCStateEx);
var
  StepsCount, i: Integer;
  lTickmarkLeft, lTickmarkTop: integer; // for drawing the decorative bars
  dRect: TRect;
  CDBarSpacing: Integer;
  lPoint: TPoint;
  pStepWidth: Double;
  lSize, lMeasureSize: TSize;
  lValue5, lValue11: Integer;
  lReachedPos: Integer;
begin
  lValue5 := DPIAdjustment(5);
  lValue11 := DPIAdjustment(11);
  // The orientation i
  if csfHorizontal in AState then lMeasureSize := ASize
  else lMeasureSize := Size(ASize.CY, ASize.CX);

  CDBarSpacing := GetMeasures(TCDTRACKBAR_LEFT_SPACING) + GetMeasures(TCDTRACKBAR_RIGHT_SPACING);

  // Preparations
  StepsCount := AStateEx.PosCount;
  if StepsCount > 0 then pStepWidth := (lMeasureSize.cx - CDBarSpacing) / (StepsCount + 1)
  else pStepWidth := 0.0;

  lReachedPos := Round(pStepWidth*AStateEx.Position);

  // Background

  ADest.Brush.Color := AStateEx.ParentRGBColor;
  ADest.Brush.Style := bsSolid;
  ADest.Pen.Style := psSolid;
  ADest.Pen.Color := AStateEx.ParentRGBColor;
  ADest.Rectangle(0, 0, ASize.cx, ASize.cy);

  // Draws the frame and its inner white area
  if csfHorizontal in AState then
  begin
    lPoint := Point(GetMeasures(TCDTRACKBAR_LEFT_SPACING),
       GetMeasures(TCDTRACKBAR_TOP_SPACING));
    lSize := Size(ASize.CX - CDBarSpacing, GetMeasures(TCDTRACKBAR_FRAME_HEIGHT));
  end
  else
  begin
    lPoint := Point(GetMeasures(TCDTRACKBAR_TOP_SPACING),
       GetMeasures(TCDTRACKBAR_LEFT_SPACING));
    lSize := Size(GetMeasures(TCDTRACKBAR_FRAME_HEIGHT), ASize.CY - CDBarSpacing);
  end;

  ADest.Brush.Color := Palette.Highlight;
  ADest.Pen.Style := psClear;
  ADest.Rectangle(Bounds(lPoint.X, lPoint.Y, lReachedPos, lSize.cy));

  ADest.Brush.Color := Palette.Window;
  ADest.Pen.Style := psClear;
  ADest.Rectangle(Bounds(lReachedPos + GetMeasures(TCDTRACKBAR_LEFT_SPACING), lPoint.Y, lSize.cx -lReachedPos -1, lSize.cy));

  DrawSunkenFrame(ADest, lPoint, lSize);

  // Draw the slider
  lTickmarkLeft := GetMeasures(TCDTRACKBAR_LEFT_SPACING) + lReachedPos;
  lTickmarkTop := GetMeasures(TCDTRACKBAR_TOP_SPACING) + GetMeasures(TCDTRACKBAR_FRAME_HEIGHT)+5;
  ADest.Pen.Style := psSolid;
  ADest.Pen.Color := clBlack;
  DrawSlider(ADest,
        Point(lTickmarkLeft-lValue5, GetMeasures(TCDTRACKBAR_TOP_SPACING)-2),
        Size(lValue11, GetMeasures(TCDTRACKBAR_FRAME_HEIGHT)+lValue5), AState);

  // Draw the focus
  if csfHasFocus in AState then
    DrawFocusRect(ADest,
      Point(1, 1),
      Size(ASize.CX - 2, ASize.CY - 2));

  ///////////////////////////
 { var
    r1: TRect;
    r2: TRect;
    pos :integer;
    HalfSlider:Integer;
  //  Color : DWORD;
  begin
    HalfSlider := FSliderwidth div 2;

    if Focused then
       InternalBitmap.canvas.Brush.Color:= WidgetSet.GetSysColor(COLOR_HOTLIGHT)
    else
       InternalBitmap.canvas.Brush.Color:= WidgetSet.GetSysColor(COLOR_BTNFACE);

    InternalBitmap.Canvas.FillRect(0, 0, InternalBitmap.Width, InternalBitmap.Height);
    r1:=rect(0, BorderWidth +2, Width, (Height - BorderWidth-2));
    WidgetSet.Frame3d(InternalBitmap.canvas.Handle, r1, BorderWidth, bvLowered);
    if fMax = 0 then
       pos:=0
    else
       pos:= trunc(Width * (FPosition / (fMax - fMin)));


    if pos < 0 then pos := HalfSlider;
    if pos < HalfSlider then pos := HalfSlider;
    if pos > Width - HalfSlider then pos:= Width - HalfSlider;

    r2:=Rect(pos - HalfSlider, 1, pos + HalfSlider,  Height-1);
    if fSeeking then
       begin
         WidgetSet.DrawFrameControl(InternalBitmap.canvas.Handle, r2, DFC_BUTTON, DFCS_PUSHED+DFCS_BUTTONPUSH);
         WidgetSet.DrawEdge(InternalBitmap.canvas.Handle, r2, EDGE_SUNKEN, BF_RECT+ BF_FLAT);
       end
    else
       begin
         WidgetSet.DrawFrameControl(InternalBitmap.canvas.Handle, r2, DFC_BUTTON, DFCS_BUTTONPUSH);
         WidgetSet.DrawEdge(InternalBitmap.canvas.Handle, r2, EDGE_Raised, BF_RECT+ BF_mono);
       end;

    if pos > SLIDERWIDTH then
       begin
          InternalBitmap.canvas.Brush.Color:= WidgetSet.GetSysColor(COLOR_HIGHLIGHT);
          InternalBitmap.Canvas.FillRect(R1.Left + (BorderWidth div 2), r1.Top + BorderWidth,
                              pos - HalfSlider, r1.Bottom - BorderWidth);
       end;
             }
end;

{ TCDListViewDrawerCommon }

initialization
  RegisterDrawer(TCDDrawerOvoPlayer.Create, dsExtra2);
end.

