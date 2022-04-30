using UnityEngine;

public class CameraZoom : MonoBehaviour
{
    [Header("Zoom")]
    public float normalFOV = 60f;
    public float zoomFOV = 20f;
    public float zoomSmooth = 5f;

    void Update() => ZoomIn();

    private void ZoomIn()
    {
        if (Input.GetMouseButton(1))
        {
            Camera.main.fieldOfView = Mathf.Lerp(Camera.main.fieldOfView, zoomFOV, Time.deltaTime * zoomSmooth);
        }
        else
        {
            Camera.main.fieldOfView = Mathf.Lerp(Camera.main.fieldOfView, normalFOV, Time.deltaTime * zoomSmooth);
        }
    }
}
