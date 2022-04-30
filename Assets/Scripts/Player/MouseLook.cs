using UnityEngine;

public class MouseLook : MonoBehaviour
{
    [Header("Look")]
    public float mouseSensitivity = 100.0f;
    public float clampAngle = 80.0f;

    private float rotX = 0.0f; // rotation around the right/x axis
    private Transform player;

    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;

        player = transform.parent;

        Vector3 rot = transform.localRotation.eulerAngles;
        rotX = rot.x;
    }

    void Update()
    {
        float mouseX = Input.GetAxis("Mouse X") * mouseSensitivity * Time.deltaTime;
        float mouseY = -Input.GetAxis("Mouse Y") * mouseSensitivity * Time.deltaTime;

        rotX += mouseY;
        rotX = Mathf.Clamp(rotX, -clampAngle, clampAngle);

        transform.localRotation = Quaternion.Euler(rotX, 0, 0);
        player.Rotate(Vector3.up * mouseX);
    }
}
