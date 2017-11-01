import * as React from "react";
import { VirtualFarmBotProps } from "../interfaces";
import { Session } from "../../../session";
import { BooleanSetting } from "../../../session_keys";
import { BotFigure } from "./bot_figure";
import { BotTrail } from "./bot_trail";

export function VirtualFarmBot(props: VirtualFarmBotProps) {
  const { mapTransformProps, plantAreaOffset } = props;
  const displayTrail = Session.getBool(BooleanSetting.displayTrail);
  const encoderFigure = Session.getBool(BooleanSetting.encoderFigure);

  return <g id="virtual-farmbot">
    <BotFigure name={"motor-position"}
      position={props.botLocationData.position}
      mapTransformProps={mapTransformProps}
      plantAreaOffset={plantAreaOffset} />
    {encoderFigure &&
      <BotFigure name={"encoder-position"}
        position={props.botLocationData.scaled_encoders}
        mapTransformProps={mapTransformProps}
        plantAreaOffset={plantAreaOffset} />}
    {displayTrail &&
      <BotTrail
        position={props.botLocationData.position}
        mapTransformProps={mapTransformProps} />}
  </g>;
}
