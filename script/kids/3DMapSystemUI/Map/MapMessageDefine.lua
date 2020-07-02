

if(not Map3DApp) then Map3DApp = {};end;

Map3DApp.Msg = {};
Map3DApp.Msg.mapViewRegionChanged = 1;
Map3DApp.Msg.onMinZoom = 2;
Map3DApp.Msg.onMaxZoom = 3;
Map3DApp.Msg.onMapDisplayStateChanged = 4;
Map3DApp.Msg.onAnimationEnd = 5;
Map3DApp.Msg.onMapItemSelect = 6;

Map3DApp.Msg.onEditTile = 7;
Map3DApp.Msg.onBuyTile = 8;
Map3DApp.Msg.onRentTile = 9;
Map3DApp.Msg.onEditTileDone = 10;
