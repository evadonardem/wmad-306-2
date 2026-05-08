<?php

namespace App\Http\Controllers;

use App\Http\Resources\LeagueResource;
use App\Models\League;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class LeagueController extends Controller
{
    public function index(Request $request)
    {
        $leagues = $request->user()->leagues()->with('seasons')->get();
        return LeagueResource::collection($leagues);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'sport' => 'required|string|max:255',
            'description' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $league = $request->user()->leagues()->create($request->all());
        $league->load('seasons');

        return (new LeagueResource($league))
            ->response()
            ->setStatusCode(201);
    }

    public function show(Request $request, $id)
    {
        $league = $request->user()->leagues()->with('seasons')->findOrFail($id);
        return new LeagueResource($league);
    }

    public function update(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'sport' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $league = $request->user()->leagues()->findOrFail($id);
        $league->update($request->all());
        $league->load('seasons');

        return new LeagueResource($league);
    }

    public function destroy(Request $request, $id)
    {
        $league = $request->user()->leagues()->findOrFail($id);
        $league->delete();

        return response()->json(['message' => 'League deleted successfully']);
    }
}
