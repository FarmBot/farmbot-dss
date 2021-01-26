const mockEditStep = jest.fn();
jest.mock("../../../api/crud", () => ({
  editStep: mockEditStep,
}));

import React from "react";
import { shallow } from "enzyme";
import { LuaTextArea } from "../tile_lua_support";
import { StepParams } from "../../interfaces";
import { Lua } from "farmbot";
import { fakeSequence } from "../../../__test_support__/fake_state/resources";
import {
  buildResourceIndex,
} from "../../../__test_support__/resource_index_builder";

describe("<LuaTextArea />", () => {
  const fakeProps = (): StepParams<Lua> => ({
    currentSequence: fakeSequence(),
    currentStep: { kind: "lua", args: { lua: "lua" } },
    dispatch: jest.fn(),
    index: 0,
    resources: buildResourceIndex([]).index,
  });

  it("changes lua", () => {
    const p = fakeProps();
    const wrapper = shallow(<LuaTextArea {...p} />);
    wrapper.find("textarea").simulate("change", {
      currentTarget: { value: "123" }
    });
    wrapper.find("textarea").simulate("blur");
    mockEditStep.mock.calls[0][0].executor(p.currentStep);
    expect(p.currentStep).toEqual({ kind: "lua", args: { lua: "123" } });
  });
});
